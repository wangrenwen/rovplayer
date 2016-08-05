package com.rovp.components
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class VolumeSlider extends Sprite
	{
		
		private var bar_control:Sprite;
		private var bg:MovieClip;
		private var bar:MovieClip;
		private var control:MovieClip;
		private var values:Number=0;
		private var minValue:Number=0;
		private var maxValue:Number=100;
		private var initializtion:Number;
		public function VolumeSlider(bg:MovieClip,bar:MovieClip, control:MovieClip, minValue:Number=0,maxValue:Number=1,initializtion:Number=0)
		{
			this.bg = bg;
			this.bar = bar;
			this.control = control;
			this.minValue=minValue;
			this.maxValue=maxValue;
			this.initializtion=initializtion;//默认位置值
			init();
		}
		
		private function init():void
		{
			
			addChild(bg);
			
			control.x=Math.abs(initializtion-minValue)/ Math.abs(maxValue-minValue)*bg.width;
			control.y=0;
			control.buttonMode=true;
			
			bar.x = bg.x;
			bar.y = bg.y;
			bar.width = control.x;
			addChild(bar);
			
			addChild(control);
			
			control.addEventListener(MouseEvent.MOUSE_DOWN,onStaDragHandler);
			control.addEventListener(Event.ADDED_TO_STAGE,onControlAddStage);
			
		}
		
		private function onControlAddStage(e:Event):void{
			control.stage.addEventListener(MouseEvent.MOUSE_UP,onStopDragHandler);
		}
		
		private function onStaDragHandler(event:MouseEvent):void
		{
			control.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMoveHandler);
			event.currentTarget.startDrag(false,new Rectangle(0,0,bg.width,0));//控制拖动局域		
		}
		
		private function onMoveHandler(event:MouseEvent):void
		{			
			var evt:Event=new Event(Event.CHANGE);
			this.value=control.x*(maxValue-minValue)/bg.width+minValue;//计算元件块位置对于的值
			bar.width = control.x;
			this.dispatchEvent(evt);
		}
		private function onStopDragHandler(event:MouseEvent):void
		{
			control.stopDrag();
			control.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMoveHandler);
		}
		
		public function set value(dataValue:Number):void
		{
			this.values=dataValue;
		}
		
		public function get value():Number
		{
			return values;
		}
		
	}
}