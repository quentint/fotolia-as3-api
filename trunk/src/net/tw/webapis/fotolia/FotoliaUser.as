package net.tw.webapis.fotolia {
	import net.tw.webapis.fotolia.abstract.FotoliaServiceRequester;
	import org.osflash.signals.Signal;
	import net.tw.webapis.fotolia.util.DataParser;
	/**
	 * Represents a Fotolia user.
	 */
	public class FotoliaUser extends FotoliaServiceRequester {
		protected var _sessionID:String;
		protected var _login:String;
		protected var _pass:String;
		//
		protected var _fetchedData:Boolean=false;
		protected var _fetchedStats:Boolean=false;
		protected var _fetchedGalleries:Boolean=false;
		protected var _galleries:Array=[];
		//
		protected var _shoppingCart:FotoliaShoppingCart;
		//
		protected var _loggedOut:Signal=new Signal(FotoliaUser);
		protected var _gotGalleries:Signal=new Signal(Array, FotoliaUser);
		protected var _createdGallery:Signal=new Signal(FotoliaUserGallery, FotoliaUser);
		protected var _internalGotData:Signal=new Signal();
		protected var _gotData:Signal=new Signal(FotoliaUser);
		protected var _internalGotStats:Signal=new Signal();
		protected var _gotStats:Signal=new Signal(FotoliaUser);
		//
		public static const METHOD_LOGOUT_USER:String='xmlrpc.logoutUser';
		public static const METHOD_GET_USER_GALLERIES:String='xmlrpc.getUserGalleries';
		public static const METHOD_CREATE_USER_GALLERY:String='xmlrpc.createUserGallery';
		public static const METHOD_GET_USER_DATA:String='xmlrpc.getUserData';
		public static const METHOD_GET_USER_STATS:String='xmlrpc.getUserStats';
		/**
		 * @param	pService	Used for its API key and fault handler
		 * @param	pSessionID	User session ID
		 * @param	pLogin		Allows you to store the user's login
		 * @param	pPass		Allows you to store the user's password
		 */
		public function FotoliaUser(pService:FotoliaService, pSessionID:String, pLogin:String=null, pPass:String=null) {
			super(pService);
			//
			_sessionID=pSessionID;
			_login=pLogin;
			_pass=pPass;
			//
			_internalGotData.add(onGotData);
			_internalGotStats.add(onGotStats);
			//
			gotGalleries.add(onGalleriesGot);
		}
		/**
		 * Will be true if a successful call to getData was made.
		 */
		public function get fetchedData():Boolean {
			return _fetchedData;
		}
		/**
		 * Will be true if a successful call to getStats was made.
		 */
		public function get fetchedStats():Boolean {
			return _fetchedStats;
		}
		/**
		 * User's session ID.
		 * Used by all user specific methods.
		 */
		public function get sessionID():String {
			return _sessionID;
		}
		/**
		 * Simple placeholder, used to store user's login.
		 */
		public function get login():String {
			return _login;
		}
		public function set login(s:String):void {
			_login=s;
		}
		/**
		 * Simple placeholder, used to store user's password.
		 */
		public function get pass():String {
			return _pass;
		}
		public function set pass(s:String):void {
			_pass=s;
		}
		/**
		 * User ID, requires a call to getData().
		 * @see	#getData()
		 */
		public function get id():uint {
			return props.id;
		}
		/**
		 * User's language ID, requires a call to getData().
		 * @see	#getData()
		 * @see FotoliaService
		 */
		public function get languageID():uint {
			return props.language_id;
		}
		/**
		 * User's language name, requires a call to getData().
		 * @see	#getData()
		 */
		public function get languageName():String {
			return props.language_name;
		}
		/**
		 * User's number of credits, requires a call to getData().
		 * @see	#getData()
		 */
		public function get nbCredits():Number {
			return props.nb_credits;
		}
		/**
		 * User's credit value, requires a call to getData().
		 * @see	#getData()
		 */
		public function get creditValue():Number {
			return props.credit_value;
		}
		/**
		 * User's currency name, requires a call to getData().
		 * @see	#getData()
		 */
		public function get currencyName():String {
			return props.currency_name;
		}
		/**
		 * User's currency symbol, requires a call to getData().
		 * @see	#getData()
		 */
		public function get currencySymbol():String {
			return props.currency_symbol;
		}
		/**
		 * User's number of uploaded medias, requires a call to getStats().
		 * @see #getStats()
		 */
		public function get nbMediaUploaded():uint {
			return props.nb_media_uploaded;
		}
		/**
		 * User's number of accepted medias, requires a call to getStats().
		 * @see #getStats()
		 */
		public function get nbMediaAccepted():uint {
			return props.nb_media_accepted;
		}
		/**
		 * User's number of purchased medias, requires a call to getStats().
		 * @see #getStats()
		 */
		public function get nbMediaPurchased():uint {
			return props.nb_media_purchased;
		}
		/**
		 * User's number of sold medias, requires a call to getStats().
		 * @see #getStats()
		 */
		public function get nbMediaSold():uint {
			return props.nb_media_sold;
		}
		/**
		 * User's absolute ranking, requires a call to getStats().
		 * @see #getStats()
		 */
		public function get rankingAbsolute():uint {
			return props.ranking_absolute;
		}
		/**
		 * User's relative ranking, requires a call to getStats().
		 * @see #getStats()
		 */
		public function get rankingRelative():uint {
			return props.ranking_relative;
		}
		/**
		 * User's shopping cart.
		 * @see FotoliaShoppingCart
		 */
		public function get shoppingCart():FotoliaShoppingCart {
			if (!_shoppingCart) _shoppingCart=new FotoliaShoppingCart(_service, this);
			return _shoppingCart;
		}
		/**
		 * Signal dispatched after a logOut call.
		 * Listeners will receive 1 argument: the target FotoliaUser.
		 * @see #logOut()
		 */
		public function get loggedOut():Signal {
			return _loggedOut;
		}
		/**
		 * Remote logOut call.
		 * @see #loggedOut
		 * @see http://us.fotolia.com/Services/API/Method/logoutUser
		 */
		public function logOut():void {
			loadRequest(
				METHOD_LOGOUT_USER,
				[key, sessionID],
				loggedOut,
				DataParser.targetHandler,
				[this]
			);
		}
		/**
		 * Signal dispatched after a getGalleries call.
		 * Listeners will receive 2 arguments: an Array of FotoliaUserGallery objects and the target FotoliaUser.
		 * @see #getGalleries()
		 */
		public function get gotGalleries():Signal {
			return _gotGalleries;
		}
		/**
		 * Remote getGalleries call.
		 * @see #gotGalleries
		 * @see http://us.fotolia.com/Services/API/Method/getUserGalleries
		 */
		public function getGalleries():void {
			loadRequest(
				METHOD_GET_USER_GALLERIES,
				[key, sessionID],
				gotGalleries,
				DataParser.arrayToUserGalleries,
				[_service, this]
			);
		}
		/**
		 * Boolean indicating if galleries have been fetched.
		 * @see getGalleries()
		 */
		public function get fetchedGalleries():Boolean {
			return _fetchedGalleries;
		}
		protected function onGalleriesGot(ugs:Array, u:FotoliaUser):void {
			_fetchedGalleries=true;
			_galleries=ugs;
		}
		/**
		 * Contains the galleries fetched by getGalleries. This Array will NOT be updated after createGallery calls!
		 * @see #getGalleries() 
		 */
		public function get galleries():Array {
			return _galleries;
		}
		/**
		 * Signal dispatched after a createGallery call.
		 * Listeners will receive 2 arguments: the newly created FotoliaUserGallery and the target FotoliaUser.
		 * @see #createGallery()
		 */
		public function get createdGallery():Signal {
			return _createdGallery;
		}
		/**
		 * Remote createGallery call.
		 * @param	name	New gallery name
		 * @see		#createdGallery
		 * @see		http://us.fotolia.com/Services/API/Method/createUserGallery
		 */
		public function createGallery(name:String):void {
			loadRequest(
				METHOD_CREATE_USER_GALLERY,
				[key, sessionID, name],
				createdGallery,
				DataParser.createdGalleryToUserGallery,
				[_service, this, name]
			);
		}
		/**
		 * Signal dispatched after a getData call.
		 * Listeners will receive 1 argument: the current FotoliaUser.
		 * Fetched data will be available throught the FotoliaUser object.
		 * @see #getData()
		 */
		public function get gotData():Signal {
			return _gotData;
		}
		/**
		 * Remote getData call.
		 * @see #gotData
		 * @see http://us.fotolia.com/Services/API/Method/getUserData
		 */
		public function getData():void {
			loadRequest(
				METHOD_GET_USER_DATA,
				[key, sessionID],
				_internalGotData
			);
		}
		protected function onGotData(o:Object):void {
			mergeProps(o);
			_fetchedData=true;
			gotData.dispatch(this);
		}
		/**
		 * Signal dispatched after a getStats call.
		 * Listeners will receive 1 argument: the current FotoliaUser.
		 * Fetched data will be available throught the FotoliaUser object.
		 * @see #getStats()
		 */
		public function get gotStats():Signal {
			return _gotStats;
		}
		/**
		 * Remote getStats call.
		 * @see #gotStats
		 * @see http://us.fotolia.com/Services/API/Method/getUserStats
		 */
		public function getStats():void {
			loadRequest(
				METHOD_GET_USER_STATS,
				[key, sessionID],
				_internalGotStats
			);
		}
		protected function onGotStats(o:Object):void {
			mergeProps(o);
			_fetchedStats=true;
			gotStats.dispatch(this);
		}
	}
}