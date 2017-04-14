package local.model
{
	import mx.utils.ObjectProxy;

	public class MstdnModel extends ObjectProxy
	{
		public function MstdnModel(){
			super();
		}
		
		[Bindable]
		public var tootId:Number;
		
		[Bindable]
		public var createDate:Date;
		
		[Bindable]
		public var accountUrl:String = "";
		[Bindable]
		public var accountId:String = "";
		[Bindable]
		public var accountName:String = "";
		
		[Bindable]
		public var content:String = "";
	}
}