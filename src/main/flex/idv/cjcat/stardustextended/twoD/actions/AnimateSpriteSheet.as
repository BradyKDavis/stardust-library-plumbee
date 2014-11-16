package idv.cjcat.stardustextended.twoD.actions {

import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
import idv.cjcat.stardustextended.twoD.handlers.DisplayObjectSpriteSheetHandler;

public class AnimateSpriteSheet extends Action2D{

    override public function update(emitter:Emitter, particle:Particle, timeDelta:Number, currentTime:Number):void {
        particle.dictionary[DisplayObjectSpriteSheetHandler.CURRENT_FRAME]++;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName():String {
        return "AnimateSpriteSheet";
    }

    override public function toXML():XML {
        var xml:XML = super.toXML();
        return xml;
    }

    override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
        super.parseXML(xml, builder);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML

}
}
