package
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.rovp.components.VolumeSlider;
	import com.rovp.uitls.DownloadInfoUitls;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.text.TextField;
	
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
	
	public class Rovplayer extends Sprite
	{
		private var factory:MediaFactory;
		private var player:MediaPlayer
		private var container:MediaContainer;
		private var resource:URLResource;
		
		
		public var controlBar:Sprite;
		public var controlBG:ControlBg;
		public var bufferingSymbol:BufferingSymbol;
		public var speedText:SpeedText;
		public var playBtn:PlayBtn;
		public var volumeBtn:VolumeBtn;
		public var volumeBg:VolumeBg;
		public var volumeBar:VolumeBar;
		public var volumeControl:VolumeControl;
		public var volumeSlider:VolumeSlider;
		public var fullscreenBtn:FullscreenBtn;
		
		public function Rovplayer()
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
			
//			var url905:String = "http://124.95.137.241:3581//uid$151758877/stamp$1469436164/keyid$67141632/auth$4dd4d307e6d3402d8d607b76c738f95e/a0000000000000000000000000000905.m3u8?bke=114.112.91.236&type=get_m3u8&host=114.112.91.236:18080&port=13528&zip=1&proto=10&ext=qtype:400,sublevel:905,b2c:1,starttime:1462218420,endtime:1462223700,oid:10017,eid:100961,f:1,p:0,m:1";
//			var url908:String = "http://114.112.91.236:18080//uid$151758877/stamp$1467944073/keyid$67141632/auth$4cffd107a27bd82b6029b064c9c9ec14/a0000000000000000000000000000908.m3u8?bke=114.112.91.236&type=get_m3u8&host=114.112.91.236:18080&port=13528&zip=1&proto=10&ext=qtype:400,sublevel:908,b2c:1,starttime:1462218420,endtime:1462223700,oid:10017,eid:100961,f:1,p:0,m:1&callback=cb";
//			playVideo(url905);
		}
		private function playVideo(url:String):void{
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
				elementLayout.scaleMode = ScaleMode.STRETCH;
				elementLayout.layoutMode = LayoutMode.NONE;
				elementLayout.verticalAlign = VerticalAlign.MIDDLE;
				elementLayout.horizontalAlign = HorizontalAlign.CENTER;
				element.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, elementLayout);
				
				container.addMediaElement( element );
				
				player.media=element;
				
				initControlBar();
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
			volumeBtn.stop();
			volumeBtn.x = 1514;
			volumeBtn.y = 50;
			volumeBtn.buttonMode = true;
			volumeBtn.addEventListener(MouseEvent.CLICK, onVolumeClick);
			
			volumeBg = new VolumeBg();
			volumeBar = new VolumeBar();
			volumeControl = new VolumeControl();
			volumeSlider = new VolumeSlider(volumeBg, volumeBar, volumeControl, 0, 1, 0.5);
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
		
		protected function onPlayClick( e:MouseEvent ):void
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
		
		protected function onMutedChange(e:AudioEvent):void{
			if(e.muted == true){
				volumeBtn.gotoAndStop("mute");
				if(volumeSlider != null)volumeSlider.mute(e.muted);
			}else{
				volumeBtn.gotoAndStop("loud");
				if(volumeSlider != null)volumeSlider.mute(e.muted);
			}
		}
		
		protected function onFullscreenClick(e:MouseEvent):void{
			if(stage.displayState == StageDisplayState.NORMAL){
				stage.displayState = StageDisplayState.FULL_SCREEN;
				fullscreenBtn.gotoAndStop("normal");
			}else{
				stage.displayState = StageDisplayState.NORMAL;
				fullscreenBtn.gotoAndStop("full");
			}
		}
		
		protected function onBufferingChange(e:BufferEvent):void{
			if(e.buffering == false){
				bufferingSymbol.visible = false;
				speedText.visible = false;
			}else{
				bufferingSymbol.visible = true;
				addChild(bufferingSymbol);
				bufferingSymbol.play();
				
				speedText.visible = true;
				addChild(speedText);
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