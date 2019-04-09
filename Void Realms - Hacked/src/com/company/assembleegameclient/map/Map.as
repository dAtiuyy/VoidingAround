package com.company.assembleegameclient.map {
import com.company.assembleegameclient.game.AGameSprite;
import com.company.assembleegameclient.map.mapoverlay.MapOverlay;
import com.company.assembleegameclient.map.partyoverlay.PartyOverlay;
import com.company.assembleegameclient.objects.BasicObject;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Party;
import com.company.assembleegameclient.objects.particles.ParticleEffect;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.ConditionEffect;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display.StageScaleMode;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import kabam.rotmg.assets.EmbeddedAssets;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.game.logging.RollingMeanLoopMonitor;
import kabam.rotmg.game.model.GameModel;
import kabam.rotmg.stage3D.GraphicsFillExtra;
import kabam.rotmg.stage3D.Object3D.Object3DStage3D;
import kabam.rotmg.stage3D.Render3D;
import kabam.rotmg.stage3D.Renderer;
import kabam.rotmg.stage3D.graphic3D.Program3DFactory;
import kabam.rotmg.stage3D.graphic3D.TextureFactory;

public class Map extends AbstractMap {

    public static const CLOTH_BAZAAR:String = "Cloth Bazaar";
    public static const NEXUS:String = "Nexus";
    public static const DAILY_QUEST_ROOM:String = "Daily Quest Room";
    public static const PET_YARD_1:String = "Pet Yard";
    public static const PET_YARD_2:String = "Pet Yard 2";
    public static const PET_YARD_3:String = "Pet Yard 3";
    public static const PET_YARD_4:String = "Pet Yard 4";
    public static const PET_YARD_5:String = "Pet Yard 5";
    public static const GUILD_HALL:String = "Guild Hall";
    public static const NEXUS_EXPLANATION:String = "Nexus_Explanation";
    public static const VAULT:String = "Vault";
    public static var forceSoftwareRender:Boolean = false;
    private static const VISIBLE_SORT_FIELDS:Array = ["sortVal_", "objectId_"];
    private static const VISIBLE_SORT_PARAMS:Array = [Array.NUMERIC, Array.NUMERIC];
    protected static const BLIND_FILTER:ColorMatrixFilter = new ColorMatrixFilter([0.05, 0.05, 0.05, 0, 0, 0.05, 0.05, 0.05, 0, 0, 0.05, 0.05, 0.05, 0, 0, 0.05, 0.05, 0.05, 1, 0]);
    public static var texture:BitmapData;

    private var loopMonitor:RollingMeanLoopMonitor;
    private var inUpdate_:Boolean = false;
    private var objsToAdd_:Vector.<BasicObject>;
    private var idsToRemove_:Vector.<int>;
    private var forceSoftwareMap:Dictionary;
    private var lastSoftwareClear:Boolean = false;
    private var darkness:DisplayObject;
    private var graphicsData_:Vector.<IGraphicsData>;
    private var graphicsDataStageSoftware_:Vector.<IGraphicsData>;
    private var graphicsData3d_:Vector.<Object3DStage3D>;
    public var visible_:Array;
    public var visibleUnder_:Array;
    public var visibleSquares_:Vector.<Square>;
    public var topSquares_:Vector.<Square>;

    public function Map(_arg_1:AGameSprite) {
        this.objsToAdd_ = new Vector.<BasicObject>();
        this.idsToRemove_ = new Vector.<int>();
        this.forceSoftwareMap = new Dictionary();
        this.darkness = new EmbeddedAssets.DarknessBackground();
        this.graphicsData_ = new Vector.<IGraphicsData>();
        this.graphicsDataStageSoftware_ = new Vector.<IGraphicsData>();
        this.graphicsData3d_ = new Vector.<Object3DStage3D>();
        this.visible_ = [];
        this.visibleUnder_ = [];
        this.visibleSquares_ = new Vector.<Square>();
        this.topSquares_ = new Vector.<Square>();
        super();
        gs_ = _arg_1;
        hurtOverlay_ = new HurtOverlay();
        gradientOverlay_ = new GradientOverlay();
        mapOverlay_ = new MapOverlay();
        partyOverlay_ = new PartyOverlay(this);
        party_ = new Party(this);
        quest_ = new Quest(this);
        this.loopMonitor = StaticInjectorContext.getInjector().getInstance(RollingMeanLoopMonitor);
        StaticInjectorContext.getInjector().getInstance(GameModel).gameObjects = goDict_;
        this.forceSoftwareMap[PET_YARD_1] = true;
        this.forceSoftwareMap[PET_YARD_2] = true;
        this.forceSoftwareMap[PET_YARD_3] = true;
        this.forceSoftwareMap[PET_YARD_4] = true;
        this.forceSoftwareMap[PET_YARD_5] = true;
        this.forceSoftwareMap["Nexus"] = true;
        this.forceSoftwareMap["Tomb of the Ancients"] = true;
        this.forceSoftwareMap["Tomb of the Ancients (Heroic)"] = true;
        this.forceSoftwareMap["Mad Lab"] = true;
        this.forceSoftwareMap["Guild Hall"] = true;
        this.forceSoftwareMap["Guild Hall 2"] = true;
        this.forceSoftwareMap["Guild Hall 3"] = true;
        this.forceSoftwareMap["Guild Hall 4"] = true;
        this.forceSoftwareMap["Cloth Bazaar"] = true;
        wasLastFrameGpu = Parameters.isGpuRender();
    }

    override public function setProps(_arg_1:int, _arg_2:int, _arg_3:String, _arg_4:int, _arg_5:Boolean, _arg_6:Boolean):void {
        width_ = _arg_1;
        height_ = _arg_2;
        name_ = _arg_3;
        back_ = _arg_4;
        allowPlayerTeleport_ = _arg_5;
        showDisplays_ = _arg_6;
        this.forceSoftwareRenderCheck(name_);
    }

    private function forceSoftwareRenderCheck(_arg_1:String):void {
        forceSoftwareRender = ((!((this.forceSoftwareMap[_arg_1] == null))) || ((WebMain.STAGE.stage3Ds[0].context3D == null)));
    }

    override public function initialize():void {
        squares_.length = (width_ * height_);
        addChild(map_);
        addChild(hurtOverlay_);
        addChild(gradientOverlay_);
        addChild(mapOverlay_);
        addChild(partyOverlay_);
        isPetYard = (name_.substr(0, 8) == "Pet Yard");
    }

    override public function dispose():void {
        var _local_1:Square;
        var _local_2:GameObject;
        var _local_3:BasicObject;
        gs_ = null;
        map_ = null;
        hurtOverlay_ = null;
        gradientOverlay_ = null;
        mapOverlay_ = null;
        partyOverlay_ = null;
        for each (_local_1 in squareList_) {
            _local_1.dispose();
        }
        squareList_.length = 0;
        squareList_ = null;
        squares_.length = 0;
        squares_ = null;
        for each (_local_2 in goDict_) {
            _local_2.dispose();
        }
        goDict_ = null;
        for each (_local_3 in boDict_) {
            _local_3.dispose();
        }
        boDict_ = null;
        merchLookup_ = null;
        player_ = null;
        party_ = null;
        quest_ = null;
        this.objsToAdd_ = null;
        this.idsToRemove_ = null;
        TextureFactory.disposeTextures();
        GraphicsFillExtra.dispose();
        Program3DFactory.getInstance().dispose();
    }

    override public function update(_arg_1:int, _arg_2:int):void {
        var _local_3:BasicObject;
        var _local_4:int;
        this.inUpdate_ = true;
        for each (_local_3 in goDict_) {
            if (!_local_3.update(_arg_1, _arg_2)) {
                this.idsToRemove_.push(_local_3.objectId_);
            }
        }
        for each (_local_3 in boDict_) {
            if (!_local_3.update(_arg_1, _arg_2)) {
                this.idsToRemove_.push(_local_3.objectId_);
            }
        }
        this.inUpdate_ = false;
        for each (_local_3 in this.objsToAdd_) {
            this.internalAddObj(_local_3);
        }
        this.objsToAdd_.length = 0;
        for each (_local_4 in this.idsToRemove_) {
            this.internalRemoveObj(_local_4);
        }
        this.idsToRemove_.length = 0;
        party_.update(_arg_1, _arg_2);
    }

    override public function pSTopW(_arg_1:Number, _arg_2:Number):Point {
        var _local_3:Square;
        for each (_local_3 in this.visibleSquares_) {
            if (((!((_local_3.faces_.length == 0))) && (_local_3.faces_[0].face_.contains(_arg_1, _arg_2)))) {
                return (new Point(_local_3.center_.x, _local_3.center_.y));
            }
        }
        return (null);
    }

    override public function setGroundTile(_arg_1:int, _arg_2:int, _arg_3:uint):void {
        var _local_8:int;
        var _local_9:int;
        var _local_10:Square;
        var _local_4:Square = this.getSquare(_arg_1, _arg_2);
        _local_4.setTileType(_arg_3);
        var _local_5:int = (((_arg_1 < (width_ - 1))) ? (_arg_1 + 1) : _arg_1);
        var _local_6:int = (((_arg_2 < (height_ - 1))) ? (_arg_2 + 1) : _arg_2);
        var _local_7:int = (((_arg_1 > 0)) ? (_arg_1 - 1) : _arg_1);
        while (_local_7 <= _local_5) {
            _local_8 = (((_arg_2 > 0)) ? (_arg_2 - 1) : _arg_2);
            while (_local_8 <= _local_6) {
                _local_9 = (_local_7 + (_local_8 * width_));
                _local_10 = squares_[_local_9];
                if (((!((_local_10 == null))) && (((_local_10.props_.hasEdge_) || (!((_local_10.tileType_ == _arg_3))))))) {
                    _local_10.faces_.length = 0;
                }
                _local_8++;
            }
            _local_7++;
        }
    }

    override public function addObj(_arg_1:BasicObject, _arg_2:Number, _arg_3:Number):void {
        _arg_1.x_ = _arg_2;
        _arg_1.y_ = _arg_3;
        if ((_arg_1 is ParticleEffect)) {
            (_arg_1 as ParticleEffect).reducedDrawEnabled = !(Parameters.data_.particleEffect);
        }
        if (this.inUpdate_) {
            this.objsToAdd_.push(_arg_1);
        }
        else {
            this.internalAddObj(_arg_1);
        }
    }

    public function internalAddObj(_arg_1:BasicObject):void {
        if (!_arg_1.addTo(this, _arg_1.x_, _arg_1.y_)) {
            return;
        }
        var _local_2:Dictionary = (((_arg_1 is GameObject)) ? goDict_ : boDict_);
        if (_local_2[_arg_1.objectId_] != null) {
            if (!isPetYard) {
                return;
            }
        }
        _local_2[_arg_1.objectId_] = _arg_1;
    }

    override public function removeObj(_arg_1:int):void {
        if (this.inUpdate_) {
            this.idsToRemove_.push(_arg_1);
        }
        else {
            this.internalRemoveObj(_arg_1);
        }
    }

    public function internalRemoveObj(_arg_1:int):void {
        var _local_2:Dictionary = goDict_;
        var _local_3:BasicObject = _local_2[_arg_1];
        if (_local_3 == null) {
            _local_2 = boDict_;
            _local_3 = _local_2[_arg_1];
            if (_local_3 == null) {
                return;
            }
        }
        _local_3.removeFromMap();
        delete _local_2[_arg_1];
    }

    public function getSquare(_arg_1:Number, _arg_2:Number):Square {
        if ((((((((_arg_1 < 0)) || ((_arg_1 >= width_)))) || ((_arg_2 < 0)))) || ((_arg_2 >= height_)))) {
            return (null);
        }
        var _local_3:int = (int(_arg_1) + (int(_arg_2) * width_));
        var _local_4:Square = squares_[_local_3];
        if (_local_4 == null) {
            _local_4 = new Square(this, int(_arg_1), int(_arg_2));
            squares_[_local_3] = _local_4;
            squareList_.push(_local_4);
        }
        return (_local_4);
    }

    public function lookupSquare(_arg_1:int, _arg_2:int):Square {
        if ((((((((_arg_1 < 0)) || ((_arg_1 >= width_)))) || ((_arg_2 < 0)))) || ((_arg_2 >= height_)))) {
            return (null);
        }
        return (squares_[(_arg_1 + (_arg_2 * width_))]);
    }

    override public function draw(camera:Camera, currentTime:int):void {
        if (wasLastFrameGpu != Parameters.isGpuRender()) {
            if ((((((wasLastFrameGpu == true)) && (!((WebMain.STAGE.stage3Ds[0].context3D == null))))) && (!(((!((WebMain.STAGE.stage3Ds[0].context3D == null))) && (!((WebMain.STAGE.stage3Ds[0].context3D.driverInfo.toLowerCase().indexOf("disposed") == -1)))))))) {
                WebMain.STAGE.stage3Ds[0].context3D.clear();
                WebMain.STAGE.stage3Ds[0].context3D.present();
            }
            else {
                map_.graphics.clear();
            }
            signalRenderSwitch.dispatch(wasLastFrameGpu);
            wasLastFrameGpu = Parameters.isGpuRender();
        }

        var rect:Rectangle = camera.clipRect_;
        var _local_18:* = (stage.scaleMode == StageScaleMode.NO_SCALE);
        var _local_19:Number = Parameters.data_["mscale"];
        if (_local_18)
        {
            x = (((-(rect.x) * 800) / WebMain.sWidth) * _local_19);
            y = (((-(rect.y) * 600) / WebMain.sHeight) * _local_19);
        }
        else
        {
            x = -(rect.x);
            y = -(rect.y);
        }

        var sy:Number = (-rect.y - rect.height / 2) / 50;
        var plrPos:Point = new Point(
                camera.x_ + sy * Math.cos(camera.angleRad_ - Math.PI / 2 ),
                camera.y_ + sy * Math.sin(camera.angleRad_ - Math.PI / 2));

        if (background_ != null) {
            background_.draw(camera, currentTime);
        }

        this.visible_.length = 0;
        this.visibleUnder_.length = 0;
        this.visibleSquares_.length = 0;
        this.topSquares_.length = 0;

        var distMax:int = camera.maxDist_;
        var xMin:int = Math.max(0, plrPos.x - distMax);
        var xMax:int = Math.min(width_ - 1, plrPos.x + distMax);
        var yMin:int = Math.max(0, plrPos.y - distMax);
        var yMax:int = Math.min(height_ - 1, plrPos.y + distMax);

        this.graphicsData_.length = 0;
        this.graphicsDataStageSoftware_.length = 0;
        this.graphicsData3d_.length = 0;

        // visible tiles
        var sqr:Square;
        for (var i:int = xMin; i <= xMax; i++) {
            for (var j:int = yMin; j <= yMax; j++) {
                sqr = squares_[i + j * width_];
                if (sqr != null) {
                    var dx:Number = plrPos.x - sqr.center_.x;
                    var dy:Number = plrPos.y - sqr.center_.y;
                    var sqrDist:Number = dx * dx + dy * dy;
                    if (sqrDist <= camera.maxDistSq_) {
                        sqr.lastVisible_ = currentTime;
                        sqr.draw(this.graphicsData_, camera, currentTime);
                        this.visibleSquares_.push(sqr);
                        if (sqr.topFace_ != null) {
                            this.topSquares_.push(sqr);
                        }
                    }
                }
            }
        }

        // visible game objects
        for each (var go:GameObject in goDict_) {
            go.drawn_ = false;
            if (go.dead_) {
                continue;
            }
            sqr = go.square_;
            if (sqr != null && sqr.lastVisible_ == currentTime) {
                go.drawn_ = true;
                go.computeSortVal(camera);
                if (go.props_.drawUnder_) {
                    if (go.props_.drawOnGround_) {
                        go.draw(this.graphicsData_, camera, currentTime);
                    }
                    this.visibleUnder_.push(go);
                }
                else {
                    this.visible_.push(go);
                }
            }
        }

        // visible basic objesetDefault("fullscreenMod", true);cts (projectiles, particles and such)
        for each (var bo:BasicObject in boDict_) {
            bo.drawn_ = false;
            sqr = bo.square_;
            if (sqr != null && sqr.lastVisible_ == currentTime) {
                bo.drawn_ = true;
                bo.computeSortVal(camera);
                this.visible_.push(bo);
            }
        }

        // draw visible under
        if (this.visibleUnder_.length > 0) {
            this.visibleUnder_.sortOn(VISIBLE_SORT_FIELDS, VISIBLE_SORT_PARAMS);
            for each (bo in this.visibleUnder_) {
                if (bo is GameObject && (bo as GameObject).props_.drawOnGround_) {
                    continue;
                }
                bo.draw(this.graphicsData_, camera, currentTime);
            }
        }

        // draw shadows
        this.visible_.sortOn(VISIBLE_SORT_FIELDS, VISIBLE_SORT_PARAMS);
        if (Parameters.data_.drawShadows) {
            for each (bo in this.visible_) {
                if (bo.hasShadow_) {
                    bo.drawShadow(this.graphicsData_, camera, currentTime);
                }
            }
        }

        // draw visible
        for each (bo in this.visible_) {
            bo.draw(this.graphicsData_, camera, currentTime);
            if (Parameters.isGpuRender()) {
                bo.draw3d(this.graphicsData3d_);
            }
        }

        // draw top squares
        if (this.topSquares_.length > 0) {
            for each (sqr in this.topSquares_) {
                sqr.drawTop(this.graphicsData_, camera, currentTime);
            }
        }

        // draw hw capable screen filters
        if (Parameters.isGpuRender() && Renderer.inGame) {
            var fIndex:uint = this.getFilterIndex();
            var r3d:Render3D = StaticInjectorContext.getInjector().getInstance(Render3D);
            r3d.dispatch(this.graphicsData_, this.graphicsData3d_, width_, height_, camera, fIndex);
            for (var i:int = 0; i < this.graphicsData_.length; i++) {
                if (this.graphicsData_[i] is GraphicsBitmapFill && GraphicsFillExtra.isSoftwareDraw(GraphicsBitmapFill(this.graphicsData_[i]))) {
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 1]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 2]);
                }
                else {
                    if (this.graphicsData_[i] is GraphicsSolidFill && GraphicsFillExtra.isSoftwareDrawSolid(GraphicsSolidFill(this.graphicsData_[i]))) {
                        this.graphicsDataStageSoftware_.push(this.graphicsData_[i]);
                        this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 1]);
                        this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 2]);
                    }
                }
            }
            if (this.graphicsDataStageSoftware_.length > 0) {
                map_.graphics.clear();
                map_.graphics.drawGraphicsData(this.graphicsDataStageSoftware_);
                if (this.lastSoftwareClear) {
                    this.lastSoftwareClear = false;
                }
            }
            else {
                if (!this.lastSoftwareClear) {
                    map_.graphics.clear();
                    this.lastSoftwareClear = true;
                }
            }
            if ((currentTime % 149) == 0) {
                GraphicsFillExtra.manageSize();
            }
        }
        else {
            map_.graphics.clear();
            map_.graphics.drawGraphicsData(this.graphicsData_);
        }

        map_.filters.length = 0;
        if (player_ != null && (player_.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.MAP_FILTER_BITMASK) != 0) {
            var filters:Array = [];
            if (player_.isDrunk()) {
                var blur:Number = 20 + 10 * Math.sin(currentTime / 1000);
                filters.push(new BlurFilter(blur, blur));
            }
            if (player_.isBlind()) {
                filters.push(BLIND_FILTER);
            }
            map_.filters = filters;
        }
        else {
            if (map_.filters.length > 0) {
                map_.filters = [];
            }
        }

        mapOverlay_.draw(camera, currentTime);
        partyOverlay_.draw(camera, currentTime);
    }

    private function getFilterIndex():uint {
        var _local1:uint;
        if (((!((player_ == null))) && (!(((player_.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.MAP_FILTER_BITMASK) == 0))))) {
            if (player_.isPaused()) {
                _local1 = Renderer.STAGE3D_FILTER_PAUSE;
            }
            else {
                if (player_.isBlind()) {
                    _local1 = Renderer.STAGE3D_FILTER_BLIND;
                }
                else {
                    if (player_.isDrunk()) {
                        _local1 = Renderer.STAGE3D_FILTER_DRUNK;
                    }
                }
            }
        }
        return (_local1);
    }


}
}//package com.company.assembleegameclient.map
