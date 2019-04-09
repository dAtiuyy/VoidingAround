package com.company.assembleegameclient.map {
import com.company.assembleegameclient.parameters.Parameters
import com.company.util.GraphicsUtil;

import flash.display.GradientType;
import flash.display.GraphicsGradientFill;
import flash.display.IGraphicsData;
import flash.display.Shape;

public class GradientOverlay extends Shape
{

    private var gradientGraphicsData_:Vector.<IGraphicsData>;

    public function GradientOverlay()
    {
        var _local_1:* = WebMain.STAGE;
        var _local_2:* = Parameters.data_.mscale;
        var _local_3:* = (_local_1.stageWidth / _local_2);
        var _local_4:* = (_local_1.stageHeight / _local_2);
        var _local_5:* = 200;
        var _local_6:* = (_local_3 - _local_5);
        var _local_7:* = 350;
        var _local_8:* = 350;
        var _local_9:* = new GraphicsGradientFill(GradientType.RADIAL, [0, 0], [0.3, 0.9], [0, 0xFF], GraphicsUtil.getGradientMatrix(_local_7, _local_8, 0, ((_local_6 - _local_7) / 2), (((_local_4 - _local_7) / 2) + ((_local_4 * 5) / 24))));
        var _local_10:* = GraphicsUtil.getRectPath(0, 0, _local_3, ((_local_4 * 29) / 24));
        this.gradientGraphicsData_ = new <IGraphicsData>[_local_9, _local_10, GraphicsUtil.END_FILL];
        graphics.drawGraphicsData(this.gradientGraphicsData_);
        visible = false;
    }
}
}//package com.company.assembleegameclient.map
