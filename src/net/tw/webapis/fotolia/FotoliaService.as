package net.tw.webapis.fotolia {
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	
	import net.tw.webapis.fotolia.abstract.FotoliaServiceRequester;
	import net.tw.webapis.fotolia.util.DataParser;
	
	import org.osflash.signals.*;

	/**
	 * Main class of the API, provides access to every features.
	 */
	public class FotoliaService extends FotoliaServiceRequester {
		protected var _key:String;
		protected var _showBusyCursor:Boolean=false;
		//
		protected var _faulted:Signal=new Signal(String, FaultEvent, Array);
		protected var _tested:Signal=new Signal(Boolean);
		protected var _gotData:Signal=new Signal(Object);
		protected var _gotColors:Signal=new Signal(Array);
		protected var _gotGalleries:Signal=new Signal(Array);
		protected var _gotCategories:Signal=new Signal(Array);
		protected var _searched:Signal=new Signal(FotoliaSearchResults);
		protected var _gotTopSales:Signal=new Signal(FotoliaSearchResults);
		protected var _gotFreeFilesOfTheDay:Signal=new Signal(FotoliaSearchResults);
		protected var _loggedInUser:Signal=new Signal(FotoliaUser);
		protected var _gotTags:Signal=new Signal(Array);
		protected var _gotCountries:Signal=new Signal(Array);
		//
		protected var _data:Object;
		protected var _colors:Array;
		protected var _galleries:Array;
		protected var _lastResults:FotoliaSearchResults;
		protected var _tags:Array;
		protected var _countries:Array;
		//
		protected var _representativeCategories:Array;
		protected var _conceptualCategories:Array;
		//
		public static const BASE_URL:String='http://www.fotolia.com/';
		//
		public static const METHOD_TEST:String='xmlrpc.test';
		public static const METHOD_GET_DATA:String='xmlrpc.getData';
		public static const METHOD_GET_COLORS:String='xmlrpc.getColors';
		public static const METHOD_GET_GALLERIES:String='xmlrpc.getGalleries';
		public static const METHOD_LOGIN_USER:String='xmlrpc.loginUser';
		public static const METHOD_GET_SEARCH_RESULTS:String='xmlrpc.getSearchResults';
		public static const METHOD_GET_TOP_SALES:String='search.getTopSales';
		public static const METHOD_GET_FREE_FILES_OF_THE_DAY:String='search.getFreeFilesOfTheDay';
		public static const METHOD_GET_TAGS:String='xmlrpc.getTags';
		public static const METHOD_GET_COUNTRIES:String='xmlrpc.getCountries';
		//
		public static const TAGS_USED:String='Used';
		public static const TAGS_SEARCHED:String='Searched';
		//
		public static const SEARCH_DEFAULT_LIMIT:uint=32;
		public static const SEARCH_MAX_LIMIT:uint=64;
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
		public static const LANG_JAPANESE:uint=9;
		public static const LANG_POLISH:uint=11;
		public static const LANG_RUSSIAN:uint=12;
		public static const LANG_CHINESE:uint=13;
		public static const LANG_TURKISH:uint=14;
		public static const LANG_KOREAN:uint=15;
		/**
		 * Default language ID used for all language-dependent methods.
		 */
		public var defaultLangID:uint=LANG_ENGLISH_US;
		/**
		 * @param	pKey	The API key provided by Fotolia
		 * @see		http://us.fotolia.com/Services/API/Introduction
		 */
		public function FotoliaService(pKey:String) {
			_key=pKey;
			super(this);
			gotCategories.add(onCategoriesGot);
			gotData.add(onDataGot);
			gotColors.add(onColorsGot);
			gotGalleries.add(onGalleriesGot);
			searched.add(onSearched);
			gotTags.add(onTagsGot);
			gotCountries.add(onCountriesGot);
		}
		/**
		 * Specify wether remote calls should show a busy cursor.
		 */
		public function get showBusyCursor():Boolean {
			return _showBusyCursor;
		}
		public function set showBusyCursor(value:Boolean):void {
			_showBusyCursor = value;
		}
		/**
		 * Utility to pick a language ID.
		 * @param	langID
		 * @return	Either the provided ID, or the defaultLangID
		 * @see		#defaultLangID
		 */
		public function autoPickLang(langID:uint=0):uint {
			return (langID==0 || langID>LANG_PORTUGUESE_BR) ? defaultLangID : langID;
		}
		/**
		 * The API key used for this service.
		 */
		override public function get key():String {
			return _key;
		}
		/**
		 * Signal dispatched when a remote call faults.
		 * Listeners will receive 3 arguments: the method called (String), the FaultEvent and the call arguments Array
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
				DataParser.getDataHandler
			);
		}
		protected function onDataGot(o:Object):void {
			_data=o;
		}
		/**
		 * Fetched Fotolia data.
		 * @see #getData()
		 */
		public function get data():Object {
			return _data;
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
		protected function onColorsGot(a:Array):void {
			_colors=a;
		}
		/**
		 * Fetched Fotolia colors.
		 * @see #getColors()
		 */
		public function get colors():Array {
			return _colors;
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
				[key, autoPickLang(langID)],
				gotGalleries,
				DataParser.arrayToGalleries,
				[this]
			);
		}
		protected function onGalleriesGot(a:Array):void {
			_galleries=a;
		}
		/**
		 * Fetched Fotolia galleries.
		 * @see #getGalleries()
		 */
		public function get galleries():Array {
			return _galleries;
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
			langID=autoPickLang(langID);
			loadRequest(
				FotoliaCategory.getCategoryMethod(type),
				[key, langID],
				gotCategories,
				DataParser.objectToCategories,
				[this, type, langID]
			);
		}
		protected function onCategoriesGot(a:Array):void {
			if (a.length==0) return;
			var firstCat:FotoliaCategory=a[0];
			if (firstCat.isRepresentative()) {
				_representativeCategories=a;
			} else {
				_conceptualCategories=a;
			}
		}
		/**
		 * Fetched representative categories.
		 * @see #getCategories()
		 */
		public function get representativeCategories():Array {
			return _representativeCategories;
		}
		/**
		 * Fetched conceptual categories.
		 * @see #getCategories()
		 */
		public function get conceptualCategories():Array {
			return _conceptualCategories;
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
		public function search(query:FotoliaSearchQuery):void {
			query.langID=autoPickLang(query.langID);
			//
			loadRequest(
				METHOD_GET_SEARCH_RESULTS,
				[key, query.searchParams],
				searched,
				DataParser.objectToSearchResults,
				[this]
			);
		}
		protected function onSearched(sr:FotoliaSearchResults):void {
			_lastResults=sr;
		}
		/**
		 * Last search results, if any.
		 * @see #search()
		 */
		public function get lastResults():FotoliaSearchResults {
			return _lastResults;
		}
		
		
		
		
		public function get gotTopSales():Signal {
			return _gotTopSales;
		}
		public function getTopSales(query:FotoliaTopSalesQuery):void {
			loadRequest(
				METHOD_GET_TOP_SALES,
				[key,
					query.period,
					FotoliaMedia.fixThumbnailSize(query.thumbnailSize),
					autoPickLang(query.langID),
					query.details ? 1 : 0,
					Math.max(0, query.offset),
					Math.min(query.limit, FotoliaService.SEARCH_MAX_LIMIT)
				],
				gotTopSales,
				DataParser.objectToSearchResults,
				[this]
			);
		}
		//
		public function get gotFreeFilesOfTheDay():Signal {
			return _gotFreeFilesOfTheDay;
		}
		public function getFreeFilesOfTheDay(query:FotoliaFreeFilesQuery):void {
			loadRequest(
				METHOD_GET_FREE_FILES_OF_THE_DAY,
				[key,
					FotoliaMedia.fixThumbnailSize(query.thumbnailSize),
					autoPickLang(query.langID),
					query.details ? 1 : 0,
					Math.max(0, query.offset),
					Math.min(query.limit, FotoliaService.SEARCH_MAX_LIMIT)
				],
				gotTopSales,
				DataParser.objectToSearchResults,
				[this]
			);
		}
		//
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
				[key, autoPickLang(langID), type],
				gotTags
			);
		}
		protected function onTagsGot(a:Array):void {
			_tags=a;
		}
		/**
		 * Fetched Fotolia tags.
		 * @see #getTags()
		 */
		public function get tags():Array {
			return _tags;
		}
		/**
		 * Signal disptached after a getCountries call.
		 * Listeners will receive 1 argument: an Array of Objects
		 * @see #getCountries()
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
				[key, autoPickLang(langID)],
				gotCountries
			);
		}
		protected function onCountriesGot(a:Array):void {
			_countries=a;
		}
		/**
		 * Fetched countries.
		 * @see #getCountries()
		 */
		public function get countries():Array {
			return _countries;
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
				DataParser.userHandler,
				[this, login, pass]
			);
		}
		public static function getLangBaseURL(langCode:String):String {
			return BASE_URL.replace('www', langCode);
		}
		public static function getLangSignUpURL(langCode:String):String {
			return getLangBaseURL(langCode)+'Member/SignUp';
		}
		public static function get languages():ArrayCollection {
			return new ArrayCollection([
				{label:'Français',		id:LANG_FRENCH,			code:'fr',	locale:'fr_FR'},
				{label:'English US',	id:LANG_ENGLISH_US,		code:'us',	locale:'en_US'},
				{label:'English UK',	id:LANG_ENGLISH_UK,		code:'en',	locale:'en_GB'},
				{label:'Deutsch',		id:LANG_GERMAN,			code:'de',	locale:'de_DE'},
				{label:'Español',		id:LANG_SPANISH,		code:'es',	locale:'es_ES'},
				{label:'Italiano',		id:LANG_ITALIAN,		code:'it',	locale:'it_IT'},
				{label:'Português PT',	id:LANG_PORTUGUESE_PT,	code:'pt',	locale:'pt_PT'},
				{label:'Português BR',	id:LANG_PORTUGUESE_BR,	code:'br',	locale:'pt_BR'},
				{label:'日本語',			id:LANG_JAPANESE,		code:'jp',	locale:'ja_JP'},
				{label:'Język polski',	id:LANG_POLISH,			code:'pl',	locale:'pl_PL'},
				{label:'Россия',		id:LANG_RUSSIAN,		code:'ru',	locale:'ru_RU'},
				{label:'中文',			id:LANG_CHINESE,		code:'cn',	locale:'zh_CN'},
				{label:'Türkçe',		id:LANG_TURKISH,		code:'tr',	locale:'tr_TR'},
				{label:'한국어',		id:LANG_KOREAN,			code:'ko',	locale:'ko_KR'}
			]);
		}
	}
}