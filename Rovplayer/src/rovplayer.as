package
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.TweenNano;
	import com.rovp.components.VolumeSlider;
	import com.rovp.uitls.DownloadInfoUitls;
	import com.rovp.uitls.QuickHotKey;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import org.denivip.osmf.plugins.HLSPluginInfo;
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.AudioEvent;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.traits.PlayState;
	import org.osmf.utils.OSMFSettings;
	
	public class rovplayer extends Sprite
	{
		private var factory:MediaFactory;
		private var player:MediaPlayer
		private var container:MediaContainer;
		private var resource:URLResource;
		
		
		private var controlBar:Sprite;
		private var controlBG:ControlBg;
		private var bufferingSymbol:BufferingSymbol;
		private var speedText:SpeedText;
		private var playBtn:PlayBtn;
		private var volumeBtn:VolumeBtn;
		private var volumeBg:VolumeBg;
		private var volumeBar:VolumeBar;
		private var volumeControl:VolumeControl;
		private var volumeSlider:VolumeSlider;
		private var fullscreenBtn:FullscreenBtn;
		
		private var _defaultMuted:Boolean = false;
		private var _defaultVolume:Number = 0.0;
		private var _wake:Boolean = true;
		private var _sleepTimer:Timer;
		private var _sleepTimeInerval:int = 5;
		private var _isControlShow:Boolean = true;
		public function rovplayer()
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			if(ExternalInterface.available)
				ExternalInterface.addCallback("playVideo",playVideo);
			
			MonsterDebugger.initialize(this);
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void{
			this.stage.scaleMode = StageScaleMode.EXACT_FIT;
			
			var url905:String = "http://124.95.137.241:3581//uid$151758877/stamp$1469436164/keyid$67141632/auth$4dd4d307e6d3402d8d607b76c738f95e/a0000000000000000000000000000905.m3u8?bke=114.112.91.236&type=get_m3u8&host=114.112.91.236:18080&port=13528&zip=1&proto=10&ext=qtype:400,sublevel:905,b2c:1,starttime:1462218420,endtime:1462223700,oid:10017,eid:100961,f:1,p:0,m:1";
//			var url908:String = "http://114.112.91.236:18080//uid$151758877/stamp$1467944073/keyid$67141632/auth$4cffd107a27bd82b6029b064c9c9ec14/a0000000000000000000000000000908.m3u8?bke=114.112.91.236&type=get_m3u8&host=114.112.91.236:18080&port=13528&zip=1&proto=10&ext=qtype:400,sublevel:908,b2c:1,starttime:1462218420,endtime:1462223700,oid:10017,eid:100961,f:1,p:0,m:1&callback=cb";
			playVideo(url905);
		}
		
		private function playVideo(url:String, config:Object = null):void{
//			config = {};
//			//一般参数
//			config.muted = false;
//			config.volume = 0.1;
//			//高级参数
//			config.clearHTTPCache = true;//防止片段请求304
//			config.hdsMinimumBufferTime = 4; //最小缓冲时间
//			config.hdsAdditionalBufferTime = 2;//附加缓冲时间
//			config.hdsBytesProcessingLimit = 102400;//视频切片尺寸
//			config.hdsBytesReadingLimit = 102400;//最大读取字节
//			config.hdsMainTimerInterval = 25;//状态自检间隔
//			config.hdsLiveStallTolerance = 15;//缓冲结束后等待播放时间
//			config.hdsMaximumRetries = 5;//流下载超时重试次数
//			config.hdsTimeoutAdjustmentOnRetry = 4000;//重试间隔时间
//			config.hdsFragmentDownloadTimeout = 4000;//片段加载超时重试间隔
//			config.hdsIndexDownloadTimeout = 4000;//索引加载超时重试间隔
			
			parseConfig(config);
			
			initMedia(url);
			
			resource = new URLResource(url);
			
			var  element:MediaElement = factory.createMediaElement(resource);
			
			if (element === null) {
				throw new Error("无法解析的视频流");
			}else{
				container.backgroundColor = 0x000000;
				container.width= stage.stageWidth;
				container.height= stage.stageHeight;
				
				var elementLayout:LayoutMetadata = new LayoutMetadata();
				elementLayout.percentWidth = 100;
				elementLayout.percentHeight = 100;
				elementLayout.scaleMode = ScaleMode.LETTERBOX;
				elementLayout.layoutMode = LayoutMode.NONE;
				elementLayout.verticalAlign = VerticalAlign.MIDDLE;
				elementLayout.horizontalAlign = HorizontalAlign.CENTER;
				element.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, elementLayout);
				
				container.addMediaElement( element );
				
				player.media=element;
				
				initControlBar();
				
				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				stage.addEventListener(MouseEvent.CLICK, onWake);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onWake);
				stage.addEventListener(MouseEvent.MOUSE_OVER, onWake);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onWake)
				
				_sleepTimer = new Timer(_sleepTimeInerval * 1000, 1);
				_sleepTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onSleepTimerComplete);
				_sleepTimer.start();
			}
		}
		
		private function parseConfig(conf:Object):void{
			for(var attr:String in conf){
				if(attr == "muted"){
					_defaultMuted = Boolean(conf[attr]);
					MonsterDebugger.log("mute is :"+conf[attr]);
					continue;
				}
				
				if(attr =="volume"){
					_defaultVolume = Number(conf[attr]);
					continue;
				}
				
				if(attr == "clearHTTPCache"){
					DownloadInfoUitls.instance.clearHTTPCache = Boolean(conf[attr]);
					MonsterDebugger.log("clearHTTPCache is :"+conf[attr]);
					continue;
				}
				
				if(OSMFSettings[attr] != null){
					OSMFSettings[attr] = int(conf[attr]);
					continue;
				}
			}
		}
		
		private function initMedia(url:String):void {		
			//TODO 解析地址是哪种流
			factory = new DefaultMediaFactory();
			factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, handlePluginLoad);
			factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, handlePluginLoadError);
			factory.loadPlugin(new PluginInfoResource(new HLSPluginInfo()));			
			
			player = new MediaPlayer();
			player.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onSizeChange );
			player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onProgress );
			player.addEventListener(MediaErrorEvent.MEDIA_ERROR, onPlayerError);
			player.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
			player.addEventListener(LoadEvent.BYTES_LOADED_CHANGE,onBytesLoadedChange);
			player.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			player.addEventListener(AudioEvent.MUTED_CHANGE,onMutedChange);
			
			player.muted = _defaultMuted;
			player.volume = _defaultVolume;
			
			container = new MediaContainer();			
			addChild(container);
		}
		
		protected function initControlBar():void
		{
			controlBar = new Sprite();
			
			controlBG = new ControlBg();
			controlBG.x = 0;
			controlBG.y = 0;
			controlBG.width = stage.stageWidth;
			
			playBtn = new PlayBtn();
			playBtn.stop();
			playBtn.x = 79;
			playBtn.y = 50;
			playBtn.buttonMode = true;
			playBtn.addEventListener(MouseEvent.CLICK, onPlayClick);
			
			volumeBtn = new VolumeBtn();
			volumeBtn.gotoAndStop(_defaultMuted == true ? "mute" : "loud");
			volumeBtn.x = 1514;
			volumeBtn.y = 50;
			volumeBtn.buttonMode = true;
			volumeBtn.addEventListener(MouseEvent.CLICK, onVolumeClick);
			
			volumeBg = new VolumeBg();
			volumeBar = new VolumeBar();
			volumeControl = new VolumeControl();
			volumeSlider = new VolumeSlider(volumeBg, volumeBar, volumeControl, 0, 1, _defaultVolume);
			volumeSlider.x = 1574;
			volumeSlider.y = 50;
			volumeSlider.addEventListener(Event.CHANGE, onVolumeChange);
			
			fullscreenBtn = new FullscreenBtn();
			fullscreenBtn.stop();
			fullscreenBtn.x = 1865;
			fullscreenBtn.y = 50;
			fullscreenBtn.buttonMode = true;
			fullscreenBtn.addEventListener(MouseEvent.CLICK, onFullscreenClick);
			
			controlBar.x =0;
			controlBar.y = 1080 - 90;
			
			this.addChild( controlBar );
			controlBar.addChild( controlBG );
			controlBar.addChild(playBtn);
			controlBar.addChild(volumeBtn);
			controlBar.addChild(volumeSlider);
			controlBar.addChild(fullscreenBtn);
			
			bufferingSymbol = new BufferingSymbol();
			bufferingSymbol.x = stage.stageWidth / 2;
			bufferingSymbol.y = stage.stageHeight / 2 - bufferingSymbol.height;
			addChild(bufferingSymbol);
			
			speedText = new SpeedText();
			speedText.mouseEnabled = false;
			speedText.mouseChildren = false;
			speedText.x = bufferingSymbol.x;
			speedText.y = bufferingSymbol.y + bufferingSymbol.height;
			addChild(speedText);
			
			DownloadInfoUitls.instance.addEventListener(Event.CHANGE, onSpeedChange);
			
			QuickHotKey.quickAddKey(this, 32, onPlayClick, false);
			QuickHotKey.quickAddKey(this, 38, onVolumeKeyUp, false);
			QuickHotKey.quickAddKey(this, 40, onVolumeKeyDown, false);
		}
		
		protected function onSleepTimerComplete(e:TimerEvent):void{
			if(player.buffering == false)_wake = false;
		}
		
		protected function onEnterFrame(e:Event):void{
			if(_wake == true && _isControlShow == false){
				showControlBar();
			}else if(_wake == false && _isControlShow == true && player.buffering == false){
				hideControlBar();
			}
		}
		
		protected function onWake(e:MouseEvent = null):void{
			if(_sleepTimer != null){
				_sleepTimer.reset();
				_sleepTimer.start();
			}
			_wake = true;
			Mouse.show();
		}
		
		protected function hideControlBar():void{
			_isControlShow = false;
			TweenNano.to(controlBar, 0.5, {y:1080});
			Mouse.hide();
		}
		
		protected function showControlBar():void{
			_isControlShow = true;
			TweenNano.to(controlBar, 0.5, {y:1080-90});
			
		}
		
		protected function onPlayerError(event:MediaErrorEvent):void{
			MonsterDebugger.log("player error" + event.error);
		}
		
		protected function handlePluginLoadError(event:MediaFactoryEvent):void
		{
			MonsterDebugger.log("hls plugin load failed");
		}
		
		protected function handlePluginLoad(event:MediaFactoryEvent):void
		{
			MonsterDebugger.log("hls plugin load sucessed");
		}
		
		protected function onSizeChange( e:DisplayObjectEvent ):void
		{
			controlBar.x = 0;
			controlBar.y = stage.stageHeight - controlBar.height;
		}
		
		protected function onProgress( e:TimeEvent ):void
		{	
		}
		
		protected function onPlayClick( e:MouseEvent = null):void
		{
			if(!player.paused){
				player.pause();
			}
			else{
				player.play();
			}
		}
		
		protected function onPlayStateChange(e:PlayEvent):void{
			if(e.playState == PlayState.PAUSED){
				playBtn.gotoAndStop("play");
			}
			if(e.playState == PlayState.PLAYING){
				playBtn.gotoAndStop("pause");
			}
		}
		
		protected function onVolumeClick(e:MouseEvent):void{
			if(player.muted){
				player.muted = false;
			}else{
				player.muted = true;
			}
		}
		
		protected function onVolumeChange(e:Event):void{
			if(volumeSlider != null){
				if(volumeSlider.value <=0)player.muted = true;
				else{
					player.muted = false;
					player.volume = volumeSlider.value;
				}
			}
		}
		
		protected function onVolumeKeyUp():void{
			player.volume += 0.1;
			player.volume = Number(player.volume.toFixed(1));
			if(volumeSlider != null)volumeSlider.value = player.volume;
			if(player.volume >0){
				player.muted = false;
			}
		}
		
		protected function onVolumeKeyDown():void{
			player.volume -= 0.1;
			player.volume = Number(player.volume.toFixed(1));
			if(volumeSlider != null)volumeSlider.value = player.volume;
			if(player.volume <=0){
				player.muted = true;
			}
		}
		
		protected function onMutedChange(e:AudioEvent):void{
			if(e.muted == true){
				if(volumeBtn != null)volumeBtn.gotoAndStop("mute");
				if(volumeSlider != null)volumeSlider.mute(e.muted);
			}else{
				if(volumeBtn != null)volumeBtn.gotoAndStop("loud");
				if(volumeSlider != null)volumeSlider.mute(e.muted);
			}
		}
		
		protected function onFullscreenClick(e:MouseEvent):void{
			if(stage.displayState == StageDisplayState.NORMAL){
				stage.displayState = StageDisplayState.FULL_SCREEN;
				if(fullscreenBtn != null)fullscreenBtn.gotoAndStop("normal");
			}else{
				stage.displayState = StageDisplayState.NORMAL;
				if(fullscreenBtn != null)fullscreenBtn.gotoAndStop("full");
			}
		}
		
		protected function onBufferingChange(e:BufferEvent):void{
			if(e.buffering == false){
				bufferingSymbol.visible = false;
				speedText.visible = false;
				hideControlBar();
				_wake = false;
			}else{
				bufferingSymbol.visible = true;
				addChild(bufferingSymbol);
				bufferingSymbol.play();
				
				speedText.visible = true;
				addChild(speedText);
				
				showControlBar();
				_wake = true;
			}
		}
		
		protected function onSpeedChange(e:Event):void{
			if(speedText != null && speedText.visible == true){
				(speedText.getChildByName("textField") as TextField).text = DownloadInfoUitls.instance.downloadSpeedFormat;
			}
		}
		
		protected function onBytesLoadedChange(e:LoadEvent):void{
		}
		
		protected function onSeek( e:MouseEvent ):void
		{
			var seekTo:Number = player.duration * ( e.target.mouseX/e.target.width );
			player.seek( seekTo );
		}
	}
}