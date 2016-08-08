package com.rovp.uitls
{
	import flash.display.DisplayObjectContainer;
	import flash.events.KeyboardEvent;

	public class QuickHotKey
	{
		private static var _DCList:Array = [];
		public function QuickHotKey()
		{
		}
		
		public static function quickAddKey(dc:DisplayObjectContainer, keyCode:int,callBack:Function, needFocus:Boolean):void{
			var obj:Object = {};
			obj.dc = dc;
			dc.stage.addEventListener(KeyboardEvent.KEY_DOWN, obj.listener = function(e:KeyboardEvent):void{
				if(e.keyCode == keyCode)
					callBack();
			});
			_DCList.push(dc);
		}
		
		public static function clearAllKey():void{
			for each(var obj:Object in _DCList){
				(obj.dc as DisplayObjectContainer).stage.removeEventListener(KeyboardEvent.KEY_DOWN, obj.listener);
			}
		}
	}
}