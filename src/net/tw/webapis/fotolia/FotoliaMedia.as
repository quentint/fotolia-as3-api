package net.tw.webapis.fotolia {
	import net.tw.webapis.fotolia.abstract.FotoliaServiceRequester;
	import flash.geom.Point;
	import org.osflash.signals.Signal;
	import net.tw.webapis.fotolia.util.DataParser;
	/**
	 * Represents a Fotolia media.
	 */
	public class FotoliaMedia extends FotoliaServiceRequester {
		protected var _internalGotData:Signal=new Signal(Object);
		protected var _gotData:Signal=new Signal(FotoliaMedia);
		//protected var _gotGalleries:Signal=new Signal(Array);
		protected var _gotComp:Signal=new Signal(Object, FotoliaMedia);
		protected var _purchased:Signal=new Signal(String, FotoliaMedia);
		//
		protected var _dataFetched:Boolean=false;
		//
		public static const SIZE_SMALL:uint=30;
		public static const SIZE_MEDIUM:uint=110;
		public static const SIZE_LARGE:uint=400;
		//
		public static const TYPE_PHOTO:uint=1;
		public static const TYPE_ILLUSTRATION:uint=2;
		public static const TYPE_VECTOR:uint=3;
		//
		public static const LICENSE_L:String='L';
		public static const LICENSE_XL:String='XL';
		public static const LICENSE_XXL:String='XXL';
		public static const LICENSE_X:String='X';
		//
		public static const METHOD_GET_MEDIA_DATA:String='xmlrpc.getMediaData';
		//public static const METHOD_GET_MEDIA_GALLERIES:String='xmlrpc.getMediaGalleries';
		public static const METHOD_GET_MEDIA_COMP:String='xmlrpc.getMediaComp';
		public static const METHOD_GET_MEDIA:String='xmlrpc.getMedia';
		/**
		 * @param	pService	Used for its API key and fault handler
		 * @param	pProps		Random properties to be passed-in
		 */
		public function FotoliaMedia(pService:FotoliaService, pProps:Object) {
			super(pService);
			_props=pProps;
		}
		/**
		 * Signal dispatched after a getData call.
		 * Listeners will receive 1 argument: the current FotoliaMedia.
		 * Fetched data will be available throught the FotoliaMedia object.
		 * @see #getData()
		 */
		public function get gotData():Signal {
			return _gotData;
		}
		/**
		 * Remote getData call.
		 * @param	thumbnailSize
		 * @param	langID
		 * @see		#gotData
		 * @see		http://us.fotolia.com/Services/API/Method/getMediaData
		 */
		public function getData(thumbnailSize:uint=110, langID:uint=0):void {
			_internalGotData.addOnce(onGotData);
			loadRequest(
				METHOD_GET_MEDIA_DATA,
				[key, id, thumbnailSize, _service.autoPickLang(langID)],
				_internalGotData
			);
		}
		protected function onGotData(o:Object):void {
			var licenses:Object={};
			for each(var l:Object in o.licenses) {
				licenses[l.name]=l.price;
			}
			o.licenses=licenses;
			//
			mergeProps(o);
			_dataFetched=true;
			gotData.dispatch(this);
		}
		/**
		 * Will be true if a successful call to getData was made.
		 */
		public function get dataFetched():Boolean {
			return _dataFetched;
		}
		/*public function get gotGalleries():Signal {
			return _gotGalleries;
		}
		public function getGalleries(langID:uint=0, pThumbnailSize:uint=110):void {
			loadRequest(
				METHOD_GET_MEDIA_GALLERIES,
				[key, id, _service.defLang(langID), pThumbnailSize],
				gotGalleries,
				DataParser.traceObject,
				[_service]
			);
		}*/
		/**
		 * Signal dispacthed after a getComp call.
		 * Listeners will receive 2 arguments: an Object (with url:String, width:uint and height:uint properties), and the target FotoliaMedia.
		 */
		public function get gotComp():Signal {
			return _gotComp;
		}
		/**
		 * Remote getComp call.
		 * @see #gotComp()
		 * @see http://us.fotolia.com/Services/API/Method/getMediaComp
		 */
		public function getComp():void {
			loadRequest(
				METHOD_GET_MEDIA_COMP,
				[key, id],
				gotComp,
				DataParser.rawObjectTargetHandler,
				[this]
			);
		}
		/**
		 * Signal dispatched after a purchse call.
		 * Listeners will receive 2 arguments: a String (the download URL) and the target FotoliaMedia.
		 * @see #purchase()
		 */
		public function get purchased():Signal {
			return _purchased;
		}
		/**
		 * Remote purchase call.
		 * @param	sessionID		A Fotolia user session ID
		 * @param	licenseName		Name of the license to use for the purchase
		 * @see		#purchased
		 * @see		http://us.fotolia.com/Services/API/Method/getMedia
		 */
		public function purchase(sessionID:String, licenseName:String):void {
			loadRequest(
				METHOD_GET_MEDIA,
				[key, sessionID, id, licenseName],
				purchased,
				DataParser.purchaseHandler,
				[this]
			);
		}
		/**
		 * Media's ID.
		 */
		public function get id():uint {
			return props.id;
		}
		/**
		 * Media's title, requires a getData call for a FotoliaCartMedia.
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get title():String {
			return props.title;
		}
		/**
		 * Media's thumbnail URL, requires a getData call for a FotoliaCartMedia.
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get thumbnailURL():String {
			return props.thumbnail_url;
		}
		/**
		 * Returns this media's URL on Fotolia's site.
		 */
		public function get url():String {
			return FotoliaService.BASE_URL+'id/'+id;
		}
		/**
		 * Media's creator ID, requires a getData call for a FotoliaCartMedia.
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get creatorID():uint {
			return props.creator_id;
		}
		/**
		 * Media's creator name, requires a getData call for a FotoliaCartMedia.
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get creatorName():String {
			return props.creator_name;
		}
		/**
		 * Media's thumbnail size, requires a getData call for a FotoliaCartMedia.
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get thumbnailSize():Point {
			return new Point(props.thumbnail_width, props.thumbnail_height);
		}
		/**
		 * Media's available licenses, requires a getData call for a FotoliaCartMedia.
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get licenses():Object {
			return props.licenses;
		}
		/**
		 * Checks if this media is available for a given license, might require a getData call.
		 * @see #licenses
		 */
		public function hasLicense(licenseName:String):Boolean {
			return licenses.hasOwnProperty(licenseName);
		}
		/**
		 * Checks if enough data has been fetched to get this media's licenses' details.
		 * @see #licensesDetails
		 */
		public function hasLicenseDetails(licenseName:String):Boolean {
			return licensesDetails.hasOwnProperty(licenseName);
		}
		/**
		 * Returns the price for a given license.
		 * @return	The price for a given license. -1 if the license is not available, or if not enought data has been fetched.
		 * @see		#licenses
		 */
		public function getLicensePrice(licenseName:String):int {
			if (!hasLicense(licenseName)) return -1;
			return licenses[licenseName];
		}
		/**
		 * Returns the details for a given license.
		 * @return	The details for a given license. null if the license is not available, or if not enought data has been fetched.
		 * @see		#licensesDetails
		 */
		public function getLicenseDetails(licenseName:String):* {
			if (!hasLicenseDetails(licenseName)) return null;
			return licensesDetails[licenseName];
		}
		/**
		 * Media's type ID, requires a getData() call.
		 * @see #getData()
		 */
		public function get typeID():uint {
			return props.media_type_id;
		}
		/**
		 * Media's country ID, requires a getData() call.
		 * @see #getData()
		 * @see FotoliaService#getCountries()
		 */
		public function get countryID():uint {
			return props.country_id;
		}
		/**
		 * Media's country name, requires a getData() call.
		 * @see #getData()
		 */
		public function get countryName():String {
			return props.country_name;
		}
		/**
		 * Media's number of views, requires a getData() call.
		 * @see #getData()
		 */
		public function get nbViews():uint {
			return props.nb_views;
		}
		/**
		 * Media's number of downloads, requires a getData() call.
		 * @see #getData()
		 */
		public function get nbDownloads():uint {
			return props.nb_downloads;
		}
		/**
		 * Media's keywords, requires a getData() call.
		 * @see #getData()
		 */
		public function get keywords():Array {
			return DataParser.objectArrayToFirstObjectItemArray(props.keywords);
		}
		/**
		 * Media's license details, requires a getData() call.
		 * @see #getData()
		 */
		public function get licensesDetails():Object {
			return props.licenses_details;
		}
		/**
		 * Media's representative category, requires a getData() call.
		 * @see #getData()
		 */
		public function get representativeCategory():Object {
			return props.cat1;
		}
		/**
		 * Media's conceptual category, requires a getData() call.
		 * @see #getData()
		 */
		public function get conceptualCategory():Object {
			return props.cat2;
		}
		/**
		 * Media's representative category hierachy, requires a getData() call.
		 * @see #getData()
		 */
		public function get representativeCategoryHierarchy():Array {
			return props.cat1_hierarchy;
		}
		/**
		 * Media's conceptual category hierarchy, requires a getData() call.
		 * @see #getData()
		 */
		public function get conceptualCategoryHierarchy():Array {
			return props.cat2_hierarchy;
		}
		/**
		 * Indicates if this media is a photo.
		 * @see #TYPE_PHOTO
		 */
		public function isPhoto():Boolean {
			return typeID==TYPE_PHOTO;
		}
		/**
		 * Indicates if this media is an illustration.
		 * @see #TYPE_ILLUSTRATION
		 */
		public function isIllustration():Boolean {
			return typeID==TYPE_ILLUSTRATION;
		}
		/**
		 * Indicates if this media is a vector.
		 * @see #TYPE_VECTOR
		 */
		public function isVector():Boolean {
			return typeID==TYPE_VECTOR;
		}
	}
}