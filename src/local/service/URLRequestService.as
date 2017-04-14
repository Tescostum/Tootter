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
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			function onComplete(event:Event):void {
				trace(event.type);
				if(event.currentTarget.data) {
					successFunc(event.currentTarget.data);
				} else {
					successFunc(null);
				}
				removeEventListener();
				loader = null;
			}
			
			function onIOError(event:IOErrorEvent):void {
				failFunc(new Error(event.text, event.errorID));
				removeEventListener();
				loader = null;
			}
			
			function onSecurityError(event:SecurityErrorEvent):void {
				failFunc(new Error(event.toString(), event.errorID));
				removeEventListener();
				loader = null;
			}
			
			function removeEventListener():void {
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
		}
	}
}