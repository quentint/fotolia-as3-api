package net.tw.webapis.fotolia.abstract {
	import net.tw.webapis.fotolia.FotoliaService;
	import org.osflash.signals.Signal;
	import net.tw.webapis.fotolia.FotoliaServiceRequest;
	/**
	 * Abstract class for all Fotolia objects that need to request the remote API.
	 */
	public class FotoliaServiceRequester {
		protected var _service:FotoliaService;
		protected var _props:Object={};
		/**
		 * @param	pService	Used for its API key and fault handler
		 */
		public function FotoliaServiceRequester(pService:FotoliaService) {
			_service=pService;
		}
		public function get key():String {
			return _service.key;
		}
		public function get props():Object {
			return _props;
		}
		protected function mergeProps(o:Object):void { 
			for (var prop:String in o) _props[prop]=o[prop];
		}
		protected function loadRequest(method:String, args:Array, resultSignal:Signal, parser:Function=null, parserParams:Array=null):FotoliaServiceRequest {
			var fsReq:FotoliaServiceRequest=new FotoliaServiceRequest(_service, method, args, resultSignal, parser, parserParams);
			fsReq.showBusyCursor=_service.showBusyCursor;
			fsReq.load();
			return fsReq;
		}
	}
}