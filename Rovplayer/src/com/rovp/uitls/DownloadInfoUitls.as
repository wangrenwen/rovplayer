package com.rovp.uitls
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class DownloadInfoUitls extends EventDispatcher
	{
		private static var _instance:DownloadInfoUitls;
		private static var _downloadSpeed:int = 0;
		private var _downloadSpeedFormat:String = "0 B/S";
		public function DownloadInfoUitls()
		{
			
		}
		
		public static function get instance():DownloadInfoUitls{
			if(_instance == null) _instance = new DownloadInfoUitls;
			return _instance;
		}
		
		public function set downloadSpeed(value:int):void{
			if(value != _downloadSpeed)
				this.dispatchEvent(new Event(Event.CHANGE));
			_downloadSpeed = value;
		}
		
		public function get downloadSpeedFormat():String{
			return formatDownloadSpeed(_downloadSpeed);
		}
		
		private function formatDownloadSpeed(speed:Number):String{
			if(speed < 1024){
				_downloadSpeedFormat = speed + " B/S";
			}
			else if(speed >= 1024 && speed < 1024 * 1024){
				_downloadSpeedFormat = (speed / 1024 >> 0) + " KB/S";
			}
			else if(speed >= 1024 * 1024){
				_downloadSpeedFormat = (speed / 1024 / 1024 >> 0)+ " MB/S";
			}
			trace(_downloadSpeedFormat);
			return _downloadSpeedFormat;
		}
	}
}