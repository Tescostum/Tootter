package local.service
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	
	import local.model.MstdnModel;
	import local.util.MstdnSharedObjectUtil;

	public class MstdnPublicStreamService
	{
		private var _util:MstdnSharedObjectUtil;
		private var TIMELINE_URL:String = "/api/v1/streaming/public";
		private var reqService:URLRequestService;
		
		private var _urlLoader:URLLoader;
		private var _urlStream:URLStream;
		private var _buffer:String;
		
		[Bindable]
		public var timeLine:ArrayCollection;
		
		public function MstdnPublicStreamService()
		{
			_util = new MstdnSharedObjectUtil();
			timeLine = new ArrayCollection();
			reqService = new URLRequestService();
			_urlStream = new URLStream();
			_buffer = "";
		}
		
		public function getTimeLine(successFunc:Function, failFunc:Function):void {
			if(!_util.isAuthrized()) {
				failFunc(new Error("認証されていません"));
				return;
			}
			
			var req:URLRequest = new URLRequest("https://" + _util.domain + TIMELINE_URL);
			req.method = URLRequestMethod.GET;
			req.requestHeaders = [];
			req.requestHeaders.push(new URLRequestHeader("Authorization", "Bearer "+ String(_util.accessToken)));
			
			streamLoadRequest(req,
				function(data:Object):void {
					if(!data) {
						failFunc(new Error("情報が取得できませんでした"));
						return;
					}
					parseStreamData(data as String);
					successFunc();
				}, function(error:Error):void {
					failFunc(error);
				}
			);
		}
		
		public function streamLoadRequest(request:URLRequest, successFunc:Function, failFunc:Function):void {
			_urlStream = new URLStream();
			var loader:URLStream = _urlStream;
			loader.load(request);
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			function onComplete(event:Event):void {
				trace(event.type);
				if(event.currentTarget.data) {
					successFunc(event.currentTarget.data);
				} else {
					successFunc(null);
				}
				removeLoaderEventListener();
				loader = null;
			}
			
			function onProgress(event:ProgressEvent):void {
				_buffer += _urlStream.readUTFBytes(_urlStream.bytesAvailable);
				if(_buffer) {
					if(_buffer.indexOf("\n") >= 0)
					{
						parseStreamData(_buffer);
					}
				}
			}
			
			function onIOError(event:IOErrorEvent):void {
				failFunc(new Error(event.text, event.errorID));
				removeLoaderEventListener();
				loader = null;
			}
			
			function onSecurityError(event:SecurityErrorEvent):void {
				failFunc(new Error(event.toString(), event.errorID));
				removeLoaderEventListener();
				loader = null;
			}
			
			function removeLoaderEventListener():void {
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
		}
		
		public function parseStreamData(data:String):void {
			var events:Array = data.split(/\r\n|\n|\r/);
			var updates:Array = [];
			var deletes:Array = [];
			var dataEvent:String = "";
			for (var i:int = 0; i < events.length; i++) {
				var elm:String = events[i];
				var splits:Array = elm.split(/\:\s/);
				var division:String = splits.length >= 2 ? splits[0] : '';
				if(division == "event") {
					var dataName:String = splits.length >= 2 ? splits[1] : '';
					dataEvent = dataName;
				} else if(division == "data") {
					var jsonStr:String = ""
					if(splits.length >= 3) {
						for (var j:int = 1; j < splits.length; j++) {
							jsonStr += splits[j] as String;
						}
					} else {
						jsonStr = splits.length >= 2 ? splits[1] : '';
					}
					execStreamData(dataEvent, jsonStr);
				}
			}
		}
		
		private function execStreamData(dataEvent:String, data:String):void {
			switch(dataEvent) {
				case "update":
					try {
						var toot:Object = JSON.parse(data);
						addToot(toot);
					} catch(error:Error) {
						trace(error.message);
					}
					
					break;
				default:
					break;
			}
			
		}
		
		private function addToot(toot:Object):void {
			var obj:MstdnModel = new MstdnModel();
			if(!toot || !toot["id"]) return;
			obj.createDate = DateFormatter.parseDateString(toot.created_at);
			obj.tootId = toot["id"];
			obj.content = toot.content;
			obj.accountId = toot.account.username;
			obj.accountName = toot.account.display_name;
			obj.accountUrl = toot.account.url;
			var added:Boolean = timeLine.source.every(
				function(elm:MstdnModel, index:int, list:Array):Boolean {
					return !(elm.tootId == toot["id"]);
				}
			);
			
			if(added) {
				timeLine.addItem(obj);
			}
			
		}
	}
}