package local.service
{
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import local.util.MstdnSharedObjectUtil;

	public class MstdnSendService
	{
		
		private var _util:MstdnSharedObjectUtil;
		private var SEND_URL:String = "https://mstdn.jp/api/v1/statuses";
		
		public function MstdnSendService()
		{
			_util = new MstdnSharedObjectUtil();
		}
		
		public function sendMessage(commentObject:Object, successFunc:Function, failFunc:Function):void {
			if(!_util.isAuthrized()) {
				failFunc(new Error("認証されていません"));
				return;
			}
			
			var req:URLRequest = new URLRequest(SEND_URL);
			req.method = URLRequestMethod.POST;
			
			req.requestHeaders = [];
			req.requestHeaders.push(new URLRequestHeader("Authorization", "Bearer "+ String(_util.accessToken)));
			
			var vari:URLVariables = new URLVariables();
			if(commentObject.warning) {
				vari["spoiler_text"] = commentObject.warning; 
			}
			vari["status"] = commentObject.message;
			vari["visibility"] = "public";
			
			req.data = vari;
			
			var reqService:URLRequestService = new URLRequestService();
			reqService.loadRequest(req,
				function(data:Object):void {
					if(!data) {
						failFunc(new Error("情報が取得できませんでした"));
						return;
					}
					var jsonStr:String = data as String;
					var jsonObj:Object = JSON.parse(jsonStr);
					
					successFunc();
				}, function(error:Error):void {
					failFunc();
				}
			);
		}
	}
}