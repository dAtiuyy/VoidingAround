package com.company.assembleegameclient.map {
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.RandomUtil;

import flash.display.StageScaleMode;
import flash.geom.Matrix3D;
import flash.geom.PerspectiveProjection;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

public class Camera {

    public static const CENTER_SCREEN_RECT:Rectangle = new Rectangle(-300, -325, 600, 600);
    public static const OFFSET_SCREEN_RECT:Rectangle = new Rectangle(-300, -450, 600, 600);
    public static var MapRectFSCentered:Rectangle = new Rectangle(-300, -325, 600, 600);
    public static var MapRectFSNonCentered:Rectangle = new Rectangle(-300, -450, 600, 600);

    private const MAX_JITTER:Number = 0.5;
    private const JITTER_BUILDUP_MS:int = 10000;

    public var x_:Number;
    public var y_:Number;
    public var z_:Number;
    public var angleRad_:Number;
    public var clipRect_:Rectangle;
    public var pp_:PerspectiveProjection;
    public var maxDist_:Number;
    public var maxDistSq_:Number;
    public var isHallucinating_:Boolean = false;
    public var wToS_:Matrix3D;
    public var wToV_:Matrix3D;
    public var vToS_:Matrix3D;
    private var nonPPMatrix_:Matrix3D;
    private var p_:Vector3D;
    private var f_:Vector3D;
    private var u_:Vector3D;
    private var r_:Vector3D;
    private var isJittering_:Boolean = false;
    private var jitter_:Number = 0;
    private var rd_:Vector.<Number>;

    public function Camera() {
        this.pp_ = new PerspectiveProjection();
        this.wToS_ = new Matrix3D();
        this.wToV_ = new Matrix3D();
        this.vToS_ = new Matrix3D();
        this.nonPPMatrix_ = new Matrix3D();
        this.p_ = new Vector3D();
        this.f_ = new Vector3D();
        this.u_ = new Vector3D();
        this.r_ = new Vector3D();
        this.rd_ = new Vector.<Number>(16, true);
        super();
        this.pp_.focalLength = 3;
        this.pp_.fieldOfView = 48;
        this.nonPPMatrix_.appendScale(50, 50, 50);
        this.f_.x = 0;
        this.f_.y = 0;
        this.f_.z = -1;
    }

    public static function resetDimensions():void
    {
        var _local_1:Number = Parameters.data_["mscale"];
        var _local_2:Number = (WebMain.sWidth / _local_1);
        var _local_3:Number = (WebMain.sHeight / _local_1);
        MapRectFSCentered = new Rectangle(-(_local_2 / 2), ((-(_local_3) * 13) / 24), _local_2, _local_3);
        MapRectFSNonCentered = new Rectangle(-(_local_2 / 2), ((-(_local_3) * 3) / 4), _local_2, _local_3);
    }

    public static function CameraRectangle(_arg_1:Boolean):Rectangle
    {
        if (Parameters.data_["stageScale"] == StageScaleMode.NO_SCALE)
        {
            if (_arg_1)
            {
                return (MapRectFSCentered);
            }
            return (MapRectFSNonCentered);
        }
        if (_arg_1)
        {
            return (CENTER_SCREEN_RECT);
        }
        return (OFFSET_SCREEN_RECT);
    }

    public function configureCamera(_arg1:GameObject, _arg2:Boolean):void {
        var cameraRect:Rectangle = CameraRectangle(Parameters.data_["centerOnPlayer"]);
        var cameraAngle:Number = Parameters.data_["cameraAngle"];
        this.configure(_arg1.x_, _arg1.y_, 12, cameraAngle, cameraRect);
        this.isHallucinating_ = _arg2;
    }

    public function startJitter():void {
        this.isJittering_ = true;
        this.jitter_ = 0;
    }

    public function update(_arg_1:Number):void {
        if (((this.isJittering_) && ((this.jitter_ < this.MAX_JITTER)))) {
            this.jitter_ = (this.jitter_ + ((_arg_1 * this.MAX_JITTER) / this.JITTER_BUILDUP_MS));
            if (this.jitter_ > this.MAX_JITTER) {
                this.jitter_ = this.MAX_JITTER;
            }
        }
    }

    public function configure(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:Number, _arg_5:Rectangle):void {
        if (this.isJittering_) {
            _arg_1 = (_arg_1 + RandomUtil.plusMinus(this.jitter_));
            _arg_2 = (_arg_2 + RandomUtil.plusMinus(this.jitter_));
        }
        this.x_ = _arg_1;
        this.y_ = _arg_2;
        this.z_ = _arg_3;
        this.angleRad_ = _arg_4;
        this.clipRect_ = _arg_5;
        this.p_.x = _arg_1;
        this.p_.y = _arg_2;
        this.p_.z = _arg_3;
        this.r_.x = Math.cos(this.angleRad_);
        this.r_.y = Math.sin(this.angleRad_);
        this.r_.z = 0;
        this.u_.x = Math.cos((this.angleRad_ + (Math.PI / 2)));
        this.u_.y = Math.sin((this.angleRad_ + (Math.PI / 2)));
        this.u_.z = 0;
        this.rd_[0] = this.r_.x;
        this.rd_[1] = this.u_.x;
        this.rd_[2] = this.f_.x;
        this.rd_[3] = 0;
        this.rd_[4] = this.r_.y;
        this.rd_[5] = this.u_.y;
        this.rd_[6] = this.f_.y;
        this.rd_[7] = 0;
        this.rd_[8] = this.r_.z;
        this.rd_[9] = -1;
        this.rd_[10] = this.f_.z;
        this.rd_[11] = 0;
        this.rd_[12] = -(this.p_.dotProduct(this.r_));
        this.rd_[13] = -(this.p_.dotProduct(this.u_));
        this.rd_[14] = -(this.p_.dotProduct(this.f_));
        this.rd_[15] = 1;
        this.wToV_.rawData = this.rd_;
        this.vToS_ = this.nonPPMatrix_;
        this.wToS_.identity();
        this.wToS_.append(this.wToV_);
        this.wToS_.append(this.vToS_);
        var _local_6:Number = (this.clipRect_.width / (2 * 50));
        var _local_7:Number = (this.clipRect_.height / (2 * 50));
        this.maxDist_ = (Math.sqrt(((_local_6 * _local_6) + (_local_7 * _local_7))) + 1);
        this.maxDistSq_ = (this.maxDist_ * this.maxDist_);
    }


}
}//package com.company.assembleegameclient.map
