package local.util
{
	import flash.net.SharedObject;

	public class MstdnSharedObjectUtil
	{
		public function MstdnSharedObjectUtil() {
			_sharedObject = SharedObject.getLocal("mstdn_sender");
		}
		
		[Bindable]
		private var _sharedObject:SharedObject;
		
		public function isAuthrized():Boolean {
			return accessToken != "";
		}
		
		private var domainReg:RegExp = /^([0-9a-zA-Z\.\-:]+?):?[0-9]*?\//i
		public function getCorrectDomain(domainStr:String):String {
			var matching:Array = domainStr.match(domainReg);
			var domain:String = "";
			if(matching && matching.length >= 2) {
				domain = matching[1];
			}
			return domain;
		}
		
		[Bindable]
		public function get domain():String {
			return _sharedObject.data["domain"] || "";
		}
		
		public function set domain(value:String):void {
			_sharedObject.data["domain"] = value;
		}
		
		[Bindable]
		public function get domainObject():Object {
			if(!_sharedObject.data["domainObject"]) {
				_sharedObject.data["domainObject"] = {};
			}
			return _sharedObject.data["domainObject"];
		}
		
		public function set domainObject(value:Object):void {
			_sharedObject.data["domainObject"] = value;
		}
		
		private function getAppointDomainObject():Object {
			if(!domain || !domainObject) return null;
			if(!domainObject[domain]) {
				domainObject[domain] = {};
			}
			return domainObject[domain];
		}
		
		[Bindable]
		public function get mailAddress():String {
			var domainObj:Object = getAppointDomainObject();
			if(!domainObj) return "";
			return domainObj["mailAddress"] || "";
		}
		
		public function set mailAddress(value:String):void {
			var domainObj:Object = getAppointDomainObject();
			if(!domainObj) {
				return;
			}
			domainObj["mailAddress"] = value;
		}
		
		[Bindable]
		public function get clientId():String {
			var domainObj:Object = getAppointDomainObject();
			if(!domainObj) return "";
			return domainObj["clientId"] || "";
		}
		
		public function set clientId(value:String):void {
			var domainObj:Object = getAppointDomainObject();
			if(!domainObj) {
				return;
			}
			domainObj["clientId"] = value;
		}
		
		[Bindable]
		public function get clientSecret():String {
			var domainObj:Object = getAppointDomainObject();
			if(!domainObj) return "";
			return domainObj["clientSecret"] || "";
		}
		
		public function set clientSecret(value:String):void {
			var domainObj:Object = getAppointDomainObject();
			if(!domainObj) {
				return;
			}
			domainObj["clientSecret"] = value;
		}
		
		[Bindable]
		public function get accessToken():String {
			var domainObj:Object = getAppointDomainObject();
			if(!domainObj) return "";
			return domainObj["accessToken"] || "";
		}
		
		public function set accessToken(value:String):void {
			var domainObj:Object = getAppointDomainObject();
			if(!domainObj) {
				return;
			}
			domainObj["accessToken"] = value;
		}
		
		[Bindable]
		public function get created_at():String {
			var domainObj:Object = getAppointDomainObject();
			if(!domainObj) return "";
			return domainObj["created_at"] || "";
		}
		
		public function set created_at(value:String):void {
			var domainObj:Object = getAppointDomainObject();
			if(!domainObj) {
				return;
			}
			_sharedObject.data["created_at"] = value;
		}
		
		public function save():void {
			if(!_sharedObject) {
				throw "保存場所がありませんでした"
			}
			try {
				_sharedObject.flush();
			} catch(error:Error) {
				throw error;
			}
		}
	}
}