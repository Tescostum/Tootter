package local.service
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class URLRequestService
	{
		public function URLRequestService()
		{
		}
		
		public function loadRequest(request:URLRequest, successFunc:Function, failFunc:Function):void {
			var loader:URLLoader = new URLLoader(request);
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				trace(event.type);
				if(event.currentTarget.data) {
					successFunc(event.currentTarget.data);
				} else {
					successFunc(null);
				}
			});
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				failFunc(new Error(event.text, event.errorID));
			});
			
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
				failFunc(new Error(event.toString(), event.errorID));
			});
		}
	}
}