package net.tw.webapis.fotolia {
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	import net.tw.webapis.fotolia.util.DataParser;
	import org.osflash.signals.*;
	import net.tw.webapis.fotolia.abstract.FotoliaServiceRequester;
	/**
	 * Main class of the API, provides access to every features.
	 */
	public class FotoliaService extends FotoliaServiceRequester {
		protected var _key:String;
		//
		protected var _faulted:Signal=new Signal(String, FaultEvent, Array);
		protected var _tested:Signal=new Signal(Boolean);
		protected var _gotData:Signal=new Signal(Object);
		protected var _gotColors:Signal=new Signal(Array);
		protected var _gotGalleries:Signal=new Signal(Array);
		protected var _gotCategories:Signal=new Signal(Array);
		protected var _searched:Signal=new Signal(FotoliaSearchResults);
		protected var _loggedInUser:Signal=new Signal(FotoliaUser);
		protected var _gotTags:Signal=new Signal(Array);
		protected var _gotCountries:Signal=new Signal(Array);
		//
		public static const METHOD_TEST:String='xmlrpc.test';
		public static const METHOD_GET_DATA:String='xmlrpc.getData';
		public static const METHOD_GET_COLORS:String='xmlrpc.getColors';
		public static const METHOD_GET_GALLERIES:String='xmlrpc.getGalleries';
		public static const METHOD_LOGIN_USER:String='xmlrpc.loginUser';
		public static const METHOD_GET_SEARCH_RESULTS:String='xmlrpc.getSearchResults';
		public static const METHOD_GET_TAGS:String='xmlrpc.getTags';
		public static const METHOD_GET_COUNTRIES:String='xmlrpc.getCountries';
		//
		public static const TAGS_USED:String='Used';
		public static const TAGS_SEARCHED:String='Searched';
		//
		public static const SEARCH_LIMIT:uint=64;
		//
		public static const SEARCH_ORDER_RELEVANCE:String='relevance';
		public static const SEARCH_ORDER_PRICE_ASC:String='price_1';
		public static const SEARCH_ORDER_CREATION_DATE_DESC:String='creation';
		public static const SEARCH_ORDER_NB_VIEWS_DESC:String='nb_views';
		public static const SEARCH_ORDER_NB_DOWNLOADS_DESC:String='nb_downloads';
		//
		public static const LANG_FRENCH:uint=1;
		public static const LANG_ENGLISH_US:uint=2;
		public static const LANG_ENGLISH_UK:uint=3;
		public static const LANG_GERMAN:uint=4;
		public static const LANG_SPANISH:uint=5;
		public static const LANG_ITALIAN:uint=6;
		public static const LANG_PORTUGUESE_PT:uint=7;
		public static const LANG_PORTUGUESE_BR:uint=8;
		//
		public var defaultLangID:uint=LANG_ENGLISH_US;
		/**
		 * @param	pKey	The API key provided by Fotolia
		 * @see		http://us.fotolia.com/Services/API/Introduction
		 */
		public function FotoliaService(pKey:String) {
			_key=pKey;
			super(this);
		}
		/**
		 * Utility to pick a language ID.
		 * @param	langID
		 * @return	Either the provided ID, or the defaultLangID
		 * @see		#defaultLangID
		 */
		public function defLang(langID:uint=0):uint {
			return langID==0 ? defaultLangID : langID;
		}
		/**
		 * The API key used for this service.
		 */
		override public function get key():String {
			return _key;
		}
		/**
		 * Signal dispatched when a remote call faults.
		 * Listeners will receive 3 arguments: the faultString, the FaultEvent and the call arguments Array
		 */
		public function get faulted():Signal {
			return _faulted;
		}
		/**
		 * Signal dispatched after a test call.
		 * Listeners will receive 1 argument: Boolean (true)
		 * @see #test()
		 */
		public function get tested():Signal {
			return _tested;
		}
		/**
		 * Remote test call.
		 * @see http://us.fotolia.com/Services/API/Method/test
		 */
		public function test():void {
			loadRequest(
				METHOD_TEST,
				[key],
				tested,
				DataParser.firstObjectItemToBoolean
			);
		}
		/**
		 * Tests a faulting call.
		 * @see #faulted
		 */
		public function testFault():void {
			loadRequest(
				'fakeMethod',
				[],
				new Signal());
		}
		/**
		 * Signal dispatched after a getData call.
		 * Listeners will receive 1 argument: Object
		 * @see #getData()
		 */
		public function get gotData():Signal {
			return _gotData;
		}
		/**
		 * Remote getData call.
		 * @see http://us.fotolia.com/Services/API/Method/getData
		 */
		public function getData():void {
			loadRequest(
				METHOD_GET_DATA,
				[key],
				gotData,
				DataParser.getDataParser
			);
		}
		/**
		 * Signal dispatched after a getColors call.
		 * Listeners will receive 1 argument: an Array of Objects
		 */
		public function get gotColors():Signal {
			return _gotColors;
		}
		/**
		 * Remote getColors call.
		 * @param	parentColorID
		 * @see		http://us.fotolia.com/Services/API/Method/getColors
		 */
		public function getColors(parentColorID:int=0):void {
			loadRequest(
				METHOD_GET_COLORS,
				[key, parentColorID],
				gotColors,
				DataParser.firstObjectItemToArray
			);
		}
		/**
		 * Signal dispatched after a getGalleries call.
		 * Listeners will receive 1 argument: an Array of FotoliaGallery objects
		 */
		public function get gotGalleries():Signal {
			return _gotGalleries;
		}
		/**
		 * Remote getGalleries call.
		 * @param	langID
		 * @see		#gotGalleries
		 * @see		FotoliaGallery
		 * @see		http://us.fotolia.com/Services/API/Method/getGalleries
		 */
		public function getGalleries(langID:uint=0):void {
			loadRequest(
				METHOD_GET_GALLERIES,
				[key, defLang(langID)],
				gotGalleries,
				DataParser.arrayToGalleries,
				[this]
			);
		}
		/**
		 * Signal dispatched after a getCategories call.
		 * Listeners will receive 1 argument: an Array of FotoliaCategory objects
		 * @see #getCategories()
		 */
		public function get gotCategories():Signal {
			return _gotCategories;
		}
		/**
		 * Remote getCategories call.
		 * @param	type	Can be either 1 (Representative) or 2 (Conceptual)
		 * @param	langID
		 * @see		#gotCategories
		 * @see		FotoliaCategory
		 * @see		http://us.fotolia.com/Services/API/Method/getCategories1
		 * @see		http://us.fotolia.com/Services/API/Method/getCategories2
		 */
		public function getCategories(type:uint=1, langID:uint=0):void {
			langID=defLang(langID);
			loadRequest(
				FotoliaCategory.getCategoryMethod(type),
				[key, langID],
				gotCategories,
				DataParser.objectToCategories,
				[this, type, langID]
			);
		}
		/**
		 * Signal dispatched after a search call.
		 * Listeners will receive 1 arguments: a FotoliaSearchResult
		 * @see		#search()
		 */
		public function get searched():Signal {
			return _searched;
		}
		/**
		 * Remote search call.
		 * @param	params
		 * @see		#searched
		 * @see		FotoliaSearchResults
		 * @see		http://us.fotolia.com/Services/API/Method/getSearchResults
		 */
		public function search(params:Object):void {
			params.language_id=defLang(params.language_id);
			//
			loadRequest(
				METHOD_GET_SEARCH_RESULTS,
				[key, params],
				searched,
				DataParser.objectToSearchResults,
				[this]
			);
		}
		/**
		 * Signal dispatched after a getTags call.
		 * Listeners will receive 1 argument: an Array of Objects
		 * @see	#getTags()
		 */
		public function get gotTags():Signal {
			return _gotTags;
		}
		/**
		 * Remote getTags call.
		 * @param	langID
		 * @param	type
		 * @see		#gotTags
		 * @see		http://us.fotolia.com/Services/API/Method/getTags
		 */
		public function getTags(langID:uint=0, type:String='Used'):void {
			loadRequest(
				METHOD_GET_TAGS,
				[key, defLang(langID), type],
				gotTags
			);
		}
		/**
		 * Signal disptached after a getCountries call.
		 * Listeners will receive 1 argument: an Array of Objects
		 * @see #getCountries
		 */
		public function get gotCountries():Signal {
			return _gotCountries;
		}
		/**
		 * Remote getCountries call.
		 * @param	langID
		 * @see		#gotCountries
		 * @see		http://us.fotolia.com/Services/API/Method/getCountries
		 */
		public function getCountries(langID:uint=0):void {
			loadRequest(
				METHOD_GET_COUNTRIES,
				[key, defLang(langID)],
				gotCountries
			);
		}
		/**
		 * Signal dispatched after a loginUser call.
		 * Listeners will receive 1 argument: a FotoliaUser object
		 * @see		#loginUser
		 * @see		FotoliaUser
		 */
		public function get loggedInUser():Signal {
			return _loggedInUser;
		}
		/**
		 * Remote loginUser call.
		 * @param	login
		 * @param	pass
		 * @see		#loggedInUser
		 * @see		http://us.fotolia.com/Services/API/Method/loginUser
		 */
		public function loginUser(login:String, pass:String):void {
			loadRequest(
				METHOD_LOGIN_USER,
				[key, login, pass],
				loggedInUser,
				DataParser.parseUser,
				[this, login, pass]
			);
		}
	}
}