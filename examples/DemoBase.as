package  
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import nest.object.Container3D;
	import nest.view.managers.BasicManager;
	import nest.view.Camera3D;
	import nest.view.ViewPort;
	
	/**
	 * DemoBase
	 * 
	 * Y
	 * |     Z
	 * |    /
	 * |   /
	 * |  /
	 * | /
	 * |/__ _ _ _ _ X
	 * 
	 * Left Handed Crood SyS.
	 * 
	 * rx = pitch
	 * ry = yaw
	 * rz = roll
	 */
	public class DemoBase extends Sprite {
		
		protected var keys:Array = new Array();
		
		protected var view:ViewPort;
		protected var camera:Camera3D;
		protected var scene:Container3D;
		protected var manager:BasicManager;
		
		protected var controller:ObjectController;
		
		protected var actived:Boolean = true;
		protected var speed:Number = 2;
		
		public function DemoBase() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
			stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
			
			camera = new Camera3D();
			scene = new Container3D();
			manager = new BasicManager();
			view = new ViewPort(800, 600, stage.stage3Ds[0], camera, scene, manager);
			
			controller = new ObjectController(camera, stage);
			
			init();
			
			addChild(view.diagram);
			
			view.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreated);
		}
		
		protected function onStageDeactived(e:Event):void {
			if (actived) {
				stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				view.diagram.message = "Paused ... ";
				actived = false;
			}
		}
		
		protected function onStageActived(e:Event):void {
			if (!actived) {
				stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				actived = true;
			}
		}
		
		protected function onRightClick(e:MouseEvent):void {
			
		}
		
		protected function onContext3DCreated(e:Event):void {
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(Event.ACTIVATE, onStageActived);
			stage.addEventListener(Event.DEACTIVATE, onStageDeactived);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function init():void {
			
		}
		
		public function loop():void {
			
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			keys[e.keyCode] = true;
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			keys[e.keyCode] = false;
		}
		
		protected function onResize(e:Event):void {
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
		}
		
		protected function onEnterFrame(e:Event):void {
			if (keys[87]) camera.translate(Vector3D.Z_AXIS, speed);
			if (keys[83]) camera.translate(Vector3D.Z_AXIS, -speed);
			if (keys[68]) camera.translate(Vector3D.X_AXIS, speed);
			if (keys[65]) camera.translate(Vector3D.X_AXIS, -speed);
			
			loop();
			
			view.calculate();
			view.diagram.message = "Objects: " + manager.numObjects + "\nTriangles: " + manager.numTriangles + "\nVertices: " + manager.numVertices;
		}
		
	}

}