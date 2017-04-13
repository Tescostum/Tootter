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
			return accessToken && created_at;
		}
		
		[Bindable]
		public function get accessToken():String {
			return _sharedObject.data["accessToken"] || "";
		}
		
		public function set accessToken(value:String):void {
			_sharedObject.data["accessToken"] = value;
		}
		
		[Bindable]
		public function get created_at():String {
			return _sharedObject.data["created_at"] || "";
		}
		
		public function set created_at(value:String):void {
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