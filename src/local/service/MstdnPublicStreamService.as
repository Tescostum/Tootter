package local.service
{
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	
	import local.model.MstdnModel;
	import local.util.MstdnSharedObjectUtil;

	public class MstdnPublicStreamService
	{
		private var _util:MstdnSharedObjectUtil;
		private var TIMELINE_URL:String = "/api/v1/streaming/public";
		
		[Bindable]
		public var timeLine:ArrayCollection;
		
		public function MstdnPublicStreamService()
		{
			_util = new MstdnSharedObjectUtil();
			timeLine = new ArrayCollection();
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
			
			var reqService:URLRequestService = new URLRequestService();
			reqService.loadRequest(req,
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
					var toot:Object = JSON.parse(data);
					addToot(toot);
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