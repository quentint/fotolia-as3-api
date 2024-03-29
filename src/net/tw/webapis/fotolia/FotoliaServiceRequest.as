package net.tw.webapis.fotolia {
	import com.ak33m.rpc.xmlrpc.XMLRPCObject;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import org.osflash.signals.*;
	import mx.rpc.AsyncToken;
	import com.ak33m.rpc.xmlrpc.XMLRPCSerializer;
	import com.ak33m.rpc.core.RPCResponder;
	import com.ak33m.rpc.core.RPCEvent;
	import net.tw.webapis.fotolia.util.DataParser;
	import flash.utils.getTimer;
	/**
	 * Represents a Fotolia XML-RPC request.
	 */
	public class FotoliaServiceRequest extends XMLRPCObject {
		protected var _service:FotoliaService;
		protected var _method:String;
		protected var _args:Array;
		protected var _resultSignal:Signal;
		protected var _parser:Function;
		protected var _parserParams:Array;
		//
		public static const ENDPOINT:String='http://api.fotolia.com/';
		public static const DESTINATION:String='Xmlrpc/rpc';
		//
		public function FotoliaServiceRequest(pService:FotoliaService, pMethod:String, pArgs:Array, pResultSignal:Signal, pParser:Function=null, pParserParams:Array=null) {
			endpoint=ENDPOINT;
			destination=DESTINATION+'?'+getTimer();
			//
			_service=pService;
			_method=pMethod;
			_args=pArgs;
			_resultSignal=pResultSignal;
			_parser=pParser;
			_parserParams=pParserParams;
		}
		protected function addListeners():void {
			addEventListener(ResultEvent.RESULT, onCallRes);
			addEventListener(FaultEvent.FAULT, onCallFault);
		}
		protected function removeListeners():void {
			removeEventListener(ResultEvent.RESULT, onCallRes);
			removeEventListener(FaultEvent.FAULT, onCallFault);
		}
		protected function onCallRes(e:ResultEvent):void {
			removeListeners();
			if (_parser!=null) {
				var toDispatch:Object=_parserParams ? _parser(e.result, _parserParams) : _parser(e.result);
				// We provide the (optional) ability to dispatch more than 1 argument, if what we get from the parser is an object with a 'res' and a 'target' properties
				if (toDispatch.hasOwnProperty('target')) {
					if (toDispatch.hasOwnProperty('res')) _resultSignal.dispatch(toDispatch.res, toDispatch.target);
					else _resultSignal.dispatch(toDispatch.target);
				}
				else _resultSignal.dispatch(toDispatch);
			} else {
				_resultSignal.dispatch(e.result);
			}
		}
		protected function onCallFault(e:FaultEvent):void {
			removeListeners();
			// We handle error 120 (This media is not part of any galleries) a bit differently
			if (e.fault.faultCode=='120') return;
			//
			_service.faulted.dispatch(_method, e, _args);
		}
		public function load():void {
			addListeners();
			makeCall(_method, _args);
		}
	}
}