package idv.cjcat.stardustextended.twoD.handlers {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.utils.Dictionary;

import idv.cjcat.stardustextended.common.emitters.Emitter;

import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
import idv.cjcat.stardustextended.twoD.display.IStardustSprite;
import idv.cjcat.stardustextended.twoD.display.SpriteSheetBitmapSlicedCache;
import idv.cjcat.stardustextended.twoD.utils.DisplayObjectPool;

public class DisplayObjectSpriteSheetHandler extends DisplayObjectHandler implements ISpriteSheetHandler
{

    public static const CURRENT_FRAME : String = "currFrame";
    private static const slicedSpriteCache : Dictionary = new Dictionary();
    private var _spriteSheetStartAtRandomFrame : Boolean;
    private var _smoothing : Boolean;
    private var _spriteSheetAnimationSpeed : uint;
    private var _pool:DisplayObjectPool;
    private var spriteCache : SpriteSheetBitmapSlicedCache;
    private var _totalFrames : uint;
    private var _bitmapData : BitmapData;
    private var _spriteSheetSliceWidth : uint;
    private var _spriteSheetSliceHeight : uint;
    private var _isSpriteSheet : Boolean;
    private var _time : Number;

    public function DisplayObjectSpriteSheetHandler(container:DisplayObjectContainer = null,
                                                    blendMode:String = "normal",
                                                    addChildMode:int = 0)
    {
        super(container, blendMode, addChildMode);
        _pool = new DisplayObjectPool();
        _pool.reset(Bitmap, null);
    }

    override public function stepBegin(emitter:Emitter, particles:Vector.<Particle>, time:Number):void
    {
        _time = time;
    }

    override public function readParticle(particle:Particle):void {
        if (_isSpriteSheet)
        {
            var currFrame : uint = particle.dictionary[CURRENT_FRAME];
            const nextFrame : uint = (currFrame + _time) % _totalFrames;
            const nextImageIndex : uint = uint(nextFrame / _spriteSheetAnimationSpeed);
            const currImageIndex : uint = uint(currFrame / _spriteSheetAnimationSpeed);
            if ( nextImageIndex != currImageIndex )
            {
                var bmp : Bitmap = Bitmap(particle.target);
                bmp.bitmapData = spriteCache.bds[nextImageIndex];
                bmp.smoothing = _smoothing;
            }
            particle.dictionary[CURRENT_FRAME] = nextFrame;
        }
        super.readParticle(particle);
    }

    override public function particleAdded(particle:Particle):void
    {
        const bmp : Bitmap = Bitmap(_pool.get());
        particle.target = bmp;

        if (_isSpriteSheet)
        {
            makeSpriteSheetCache();
            var currFrame:uint = 0;
            if (_spriteSheetStartAtRandomFrame)
            {
                currFrame = Math.random() * _totalFrames;
            }
            bmp.bitmapData = spriteCache.bds[uint(currFrame / _spriteSheetAnimationSpeed)];
            particle.dictionary[CURRENT_FRAME] = currFrame;
        }
        else
        {
            bmp.bitmapData = _bitmapData;
        }
        bmp.smoothing = _smoothing;
        bmp.x = - bmp.width * 0.5;
        bmp.y = - bmp.height * 0.5;
        super.particleAdded(particle);
    }

    override public function particleRemoved(particle:Particle):void
    {
        super.particleRemoved(particle);
        var obj:DisplayObject = DisplayObject(particle.target);
        if (obj)
        {
            if (obj is IStardustSprite) IStardustSprite(obj).disable();
            _pool.recycle(obj);
        }
    }

    public function set bitmapData(bitmapData : BitmapData) :void
    {
        _bitmapData = bitmapData;
        makeSpriteSheetCache();
    }

    public function get bitmapData() : BitmapData
    {
        return _bitmapData;
    }

    public function set spriteSheetSliceWidth(value:uint):void {
        _spriteSheetSliceWidth = value;
        makeSpriteSheetCache();
    }

    public function get spriteSheetSliceWidth() : uint {
        return _spriteSheetSliceWidth;
    }

    public function set spriteSheetSliceHeight(value:uint):void {
        _spriteSheetSliceHeight = value;
        makeSpriteSheetCache();
    }

    public function get spriteSheetSliceHeight() : uint {
        return _spriteSheetSliceHeight;
    }

    public function set spriteSheetAnimationSpeed(spriteSheetAnimationSpeed:uint):void {
        _spriteSheetAnimationSpeed = spriteSheetAnimationSpeed;
        makeSpriteSheetCache();
    }

    public function get spriteSheetAnimationSpeed():uint {
        return _spriteSheetAnimationSpeed;
    }

    public function set spriteSheetStartAtRandomFrame(spriteSheetStartAtRandomFrame:Boolean):void {
        _spriteSheetStartAtRandomFrame = spriteSheetStartAtRandomFrame;
    }

    public function get spriteSheetStartAtRandomFrame():Boolean {
        return _spriteSheetStartAtRandomFrame;
    }

    public function get isSpriteSheet():Boolean {
        return _isSpriteSheet;
    }

    public function get smoothing():Boolean {
        return _smoothing;
    }

    public function set smoothing(value:Boolean):void {
        _smoothing = value;
    }

    private function makeSpriteSheetCache() :void
    {
        if (_bitmapData == null || _spriteSheetSliceWidth == 0 || _spriteSheetSliceHeight == 0)
        {
            return;
        }
        _isSpriteSheet = _bitmapData.width > _spriteSheetSliceWidth || _bitmapData.height > _spriteSheetSliceHeight;
        if (_isSpriteSheet) {
            if (!slicedSpriteCache[_bitmapData]) {
                slicedSpriteCache[_bitmapData] = new Dictionary();
            }
            const sizeKey:Number = _spriteSheetSliceWidth * 10000000 + _spriteSheetSliceHeight;
            if (!slicedSpriteCache[_bitmapData][sizeKey]) {
                slicedSpriteCache[_bitmapData][sizeKey] = new SpriteSheetBitmapSlicedCache(_bitmapData, _spriteSheetSliceWidth, _spriteSheetSliceHeight);
            }
            spriteCache = slicedSpriteCache[_bitmapData][sizeKey];
            _totalFrames = _spriteSheetAnimationSpeed * spriteCache.bds.length;
        }
    }

    public static function clearCache() :void
    {
        for each (var key : Dictionary in slicedSpriteCache)
        {
            delete slicedSpriteCache[key];
        }
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName():String {
        return "DisplayObjectSpriteSheetHandler";
    }

    override public function toXML():XML {
        var xml:XML = super.toXML();

        xml.@imgWidth = _spriteSheetSliceWidth;
        xml.@imgHeight = _spriteSheetSliceHeight;
        xml.@animSpeed = _spriteSheetAnimationSpeed;
        xml.@startAtRandomFrame = _spriteSheetStartAtRandomFrame;
        xml.@smoothing = _smoothing;
        return xml;
    }

    override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
        super.parseXML(xml, builder);

        _spriteSheetSliceWidth = xml.@imgWidth;
        _spriteSheetSliceHeight = xml.@imgHeight;
        spriteSheetAnimationSpeed = xml.@animSpeed;
        spriteSheetStartAtRandomFrame = (xml.@startAtRandomFrame == "true");
        _smoothing = (xml.@smoothing == "true");
    }

    //------------------------------------------------------------------------------------------------
}
}
