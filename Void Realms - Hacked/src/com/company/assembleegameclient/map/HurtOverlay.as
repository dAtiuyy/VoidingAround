package com.company.assembleegameclient.map {
import com.company.assembleegameclient.parameters.Parameters
import com.company.util.GraphicsUtil;

import flash.display.GradientType;
import flash.display.GraphicsGradientFill;
import flash.display.GraphicsPath;
import flash.display.IGraphicsData;
import flash.display.Shape;

public class HurtOverlay extends Shape
{

    private static var s:Number = (600 / Math.sin((Math.PI / 4)));
    private static var gradientFill_:GraphicsGradientFill = new GraphicsGradientFill(GradientType.RADIAL, [0xFFFFFF, 0xFFFFFF, 0xFFFFFF], [0, 0, 0.92], [0, 155, 0xFF], GraphicsUtil.getGradientMatrix(s, s, 0, ((600 - s) / 2), ((600 - s) / 2)));
    private static var gradientPath_:GraphicsPath = GraphicsUtil.getRectPath(0, 0, 600, 600);

    private const gradientGraphicsData_:Vector.<IGraphicsData> = new <IGraphicsData>[gradientFill_, gradientPath_, GraphicsUtil.END_FILL];

    public function HurtOverlay()
    {
        var _local_1:* = WebMain.STAGE;
        var _local_2:* = Parameters.data_.mscale;
        var _local_3:* = (_local_1.stageWidth / _local_2);
        var _local_4:* = (_local_1.stageHeight / _local_2);
        var _local_5:* = 200;
        var _local_6:* = (_local_3 - _local_5);
        var _local_7:* = (_local_6 / Math.sin((Math.PI / 4)));
        var _local_8:* = (_local_4 / Math.sin((Math.PI / 4)));
        gradientFill_ = new GraphicsGradientFill(GradientType.RADIAL, [0xFFFFFF, 0xFFFFFF, 0xFFFFFF], [0, 0, 0.92], [0, 155, 0xFF], GraphicsUtil.getGradientMatrix(_local_7, _local_8, 0, ((_local_6 - _local_7) / 2), ((_local_4 - _local_8) / 2)));
        gradientPath_ = GraphicsUtil.getRectPath(0, 0, _local_3, _local_4);
        graphics.drawGraphicsData(this.gradientGraphicsData_);
        visible = false;
    }

}

}//package com.company.assembleegameclient.map
