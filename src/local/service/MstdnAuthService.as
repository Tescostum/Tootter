package local.service
{
	import flash.geom.Utils3D;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import local.util.MstdnSharedObjectUtil;

	public class MstdnAuthService
	{
		private static const CLIENT_NAME:String = "トゥーッター";
		
		private static const REDIRECT_URL:String = "urn:ietf:wg:oauth:2.0:oob";
		private static const APP_REQUEST_URL:String = "/api/v1/apps";
		private static const APP_OAUTH_URL:String = "/oauth/token";
		private static const APP_SCOPE:String = "read write follow";
		
		private var _util:MstdnSharedObjectUtil;
		
		public function MstdnAuthService() {
			_util = new MstdnSharedObjectUtil();
		}
		
		public function requestClientKey(successFunc:Function, failFunc:Function):void {
			var req:URLRequest = new URLRequest("https://" + _util.domain + APP_REQUEST_URL);
			req.method = URLRequestMethod.POST;
			
			var vari:URLVariables = new URLVariables();
			vari["client_name"] = CLIENT_NAME;
			vari["redirect_uris"] = REDIRECT_URL;
			vari["scopes"] = "read write follow";
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
					
					saveClientData(jsonObj, successFunc, failFunc);
				}, function(error:Error):void {
					failFunc(error);
				}
			);
		}
		
		private function saveClientData(jsonObj:Object, successFunc:Function, failFunc:Function):void {
			if(!_util.clientId || !_util.clientSecret) {
				trace("redistered: ", _util.domain);
				_util.clientId = jsonObj["client_id"];
				_util.clientSecret = jsonObj["client_secret"];
			}
			
			try {
				_util.save();
				successFunc();
			} catch(error:Error) {
				failFunc(error);
			}
		}
		
		public function requestAccessToken(username:String, password:String, successFunc:Function, failFunc:Function):void {
			var req:URLRequest = new URLRequest("https://" + _util.domain + APP_OAUTH_URL);
			req.method = URLRequestMethod.POST;
			
			var vari:URLVariables = new URLVariables();
			vari["client_id"] = _util.clientId;
			vari["client_secret"] = _util.clientSecret;
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
			if(!_util.accessToken) {
				trace("redistered: ", _util.domain);
				_util.accessToken = jsonObj["access_token"];
				_util.created_at = jsonObj["created_at"];
			}
			try {
				_util.save();
				successFunc();
			} catch(error:Error) {
				failFunc(error);
			}
		}
	}
}