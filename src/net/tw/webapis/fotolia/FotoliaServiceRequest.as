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
		public function FotoliaServiceRequest(pService:FotoliaService, pMethod:String, pArgs:Array, pResultSignal:Signal, pParser:Function=null, pParserParams:Array=null) {
			endpoint='http://api.fotolia.com/';
			destination='Xmlrpc/rpc';
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
				if (_parserParams) _resultSignal.dispatch(_parser(e.result, _parserParams));
				else _resultSignal.dispatch(_parser(e.result));
			} else {
				_resultSignal.dispatch(e.result);
			}
		}
		protected function onCallFault(e:FaultEvent):void {
			removeListeners();
			_service.faulted.dispatch(_method, e, _args);
		}
		public function load():void {
			addListeners();
			makeCall(_method, _args);
		}
	}
}