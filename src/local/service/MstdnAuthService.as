package local.service
{
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import local.util.MstdnSharedObjectUtil;

	public class MstdnAuthService
	{
		private static const CLIENT_NAME:String = "トゥーッター";
		private static const CLIENT_ID:String = "ba4297c35e3fbb5020abcb436aa842a69192353fc8621a900219b06e9dee0a2f"/*YOUR_CLIANT_ID*/;
		private static const CLIENT_SECRET:String = "dabc5b375e0f290db2ac882f3e8b14f673fbdbbafc1ad3cfa39ea4d343ecd611"/*YOUR_CLIANT_SECRET_KEY*/;
		
		private static const REDIRECT_URL:String = "urn:ietf:wg:oauth:2.0:oob";
		private static const APP_REQUEST_URL:String = "https://mstdn.jp/api/v1/apps";
		private static const APP_OAUTH_URL:String = "https://mstdn.jp/oauth/token";
		private static const APP_SCOPE:String = "read write follow";
		
		private var _util:MstdnSharedObjectUtil;
		
		public function MstdnAuthService() {
			_util = new MstdnSharedObjectUtil();
		}
		
		public function requestAccessToken(username:String, password:String, successFunc:Function, failFunc:Function):void {
			var req:URLRequest = new URLRequest("https://mstdn.jp/oauth/token");
			req.method = URLRequestMethod.POST;
			
			var vari:URLVariables = new URLVariables();
			vari["client_id"] = CLIENT_ID;
			vari["client_secret"] = CLIENT_SECRET;
			vari["grant_type"] = "password";
			vari["username"] = username;
			vari["password"] = password;
			vari["scope"] = "read write follow";
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
					
					saveTokenData(jsonObj, successFunc, failFunc);
				}, function(error:Error):void {
					failFunc(error);
				}
			);
		}
		
		private function saveTokenData(jsonObj:Object, successFunc:Function, failFunc:Function):void {
			_util.accessToken = jsonObj["access_token"];
			_util.created_at = jsonObj["created_at"];
			
			try {
				_util.save();
				successFunc();
			} catch(error:Error) {
				failFunc(error);
			}
		}
	}
}