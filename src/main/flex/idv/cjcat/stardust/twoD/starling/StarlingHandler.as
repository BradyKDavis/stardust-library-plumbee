package idv.cjcat.stardust.twoD.starling
{

import idv.cjcat.stardust.common.handlers.ParticleHandler;
import idv.cjcat.stardust.common.particles.Particle;
import idv.cjcat.stardust.common.xml.XMLBuilder;
import idv.cjcat.stardust.twoD.display.AddChildMode;
import idv.cjcat.stardust.twoD.particles.Particle2D;

import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

public class StarlingHandler extends ParticleHandler
{
    public var addChildMode:int;
    public var container:DisplayObjectContainer;
    public var blendMode:String = BlendMode.NORMAL;

    public function StarlingHandler(container:DisplayObjectContainer = null, blendMode:String = "normal", addChildMode:int = 0)
    {
        this.container = container;
        this.blendMode = blendMode;
        this.addChildMode = addChildMode;
    }

    private var p2D:Particle2D;
    private var displayObj:DisplayObject;

    override public function particleAdded(particle:Particle):void
    {
        displayObj = DisplayObject(particle.target);
        displayObj.blendMode = blendMode;

        if (!container) return;

        switch (addChildMode)
        {
            default:
            case AddChildMode.RANDOM:
                container.addChildAt(displayObj, Math.floor(Math.random() * container.numChildren));
                break;
            case AddChildMode.TOP:
                container.addChild(displayObj);
                break;
            case AddChildMode.BOTTOM:
                container.addChildAt(displayObj, 0);
                break;
        }
    }

    override public function particleRemoved(particle:Particle):void
    {
        DisplayObject(particle.target).removeFromParent();
    }

    override public function readParticle(particle:Particle):void
    {
        p2D = Particle2D(particle);
        displayObj = DisplayObject(particle.target);

        displayObj.x = p2D.x;
        displayObj.y = p2D.y;
        displayObj.rotation = p2D.rotation;
        displayObj.scaleX = displayObj.scaleY = p2D.scale;
        displayObj.alpha = p2D.alpha;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName():String {
        return "StarlingHandler";
    }

    override public function toXML():XML {
        var xml:XML = super.toXML();

        xml.@addChildMode = addChildMode;
        xml.@blendMode = blendMode;

        return xml;
    }

    override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
        super.parseXML(xml, builder);

        if (xml.@addChildMode.length()) addChildMode = parseInt(xml.@addChildMode);
        if (xml.@blendMode.length()) blendMode = (xml.@blendMode);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML


}
}