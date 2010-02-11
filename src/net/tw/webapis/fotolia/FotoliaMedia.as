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
		public static const SIZE_SMALL:uint=30;
		public static const SIZE_MEDIUM:uint=110;
		public static const SIZE_LARGE:uint=400;
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
				[key, id, thumbnailSize, _service.defLang(langID)],
				_internalGotData
			);
		}
		protected function onGotData(o:Object):void {
			mergeProps(o);
			gotData.dispatch(this);
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
		 * @param	licenceName		Name of the licence to use for the purchase
		 * @see		#purchased
		 * @see		http://us.fotolia.com/Services/API/Method/getMedia
		 */
		public function purchase(sessionID:String, licenceName:String):void {
			loadRequest(
				METHOD_GET_MEDIA,
				[key, sessionID, id, licenceName],
				purchased,
				DataParser.purchaseHandler,
				[this]
			);
		}
		/**
		 * Media's ID
		 */
		public function get id():uint {
			return props.id;
		}
		/**
		 * Media's title, requires a getData call for a FotoliaCartMedia
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get title():String {
			return props.title;
		}
		/**
		 * Media's thumbnail URL, requires a getData call for a FotoliaCartMedia
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get thumbnailURL():String {
			return props.thumbnail_url;
		}
		/**
		 * Media's creator ID, requires a getData call for a FotoliaCartMedia
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get creatorID():uint {
			return props.creator_id;
		}
		/**
		 * Media's creator name, requires a getData call for a FotoliaCartMedia
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get creatorName():String {
			return props.creator_name;
		}
		/**
		 * Media's thumbnail size, requires a getData call for a FotoliaCartMedia
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get thumbnailSize():Point {
			return new Point(props.thumbnail_width, props.thumbnail_height);
		}
		/**
		 * Media's available licences, requires a getData call for a FotoliaCartMedia
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get licenses():Array {
			return props.licenses;
		}
		/**
		 * Media's type ID, requires a getData() call
		 * @see #getData()
		 */
		public function get mediaTypeID():uint {
			return props.media_type_id;
		}
		/**
		 * Media's country ID, requires a getData() call
		 * @see #getData()
		 * @see FotoliaService#getCountries()
		 */
		public function get countryID():uint {
			return props.country_id;
		}
		/**
		 * Media's country name, requires a getData() call
		 * @see #getData()
		 */
		public function get countryName():String {
			return props.country_name;
		}
		/**
		 * Media's number of views, requires a getData() call
		 * @see #getData()
		 */
		public function get nbViews():uint {
			return props.nb_views;
		}
		/**
		 * Media's number of downloads, requires a getData() call
		 * @see #getData()
		 */
		public function get nbDownloads():uint {
			return props.nb_downloads;
		}
		/**
		 * Media's keywords, requires a getData() call
		 * @see #getData()
		 */
		public function get keywords():Array {
			return DataParser.objectArrayToFirstObjectItemArray(props.keywords);
		}
		/**
		 * Media's licence details, requires a getData() call
		 * @see #getData()
		 */
		public function get licensesDetails():Object {
			return props.licenses_details;
		}
		/**
		 * Media's representative category, requires a getData() call
		 * @see #getData()
		 */
		public function get representativeCategory():Object {
			return props.cat1;
		}
		/**
		 * Media's conceptual category, requires a getData() call
		 * @see #getData()
		 */
		public function get conceptualCategory():Object {
			return props.cat2;
		}
		/**
		 * Media's representative category hierachy, requires a getData() call
		 * @see #getData()
		 */
		public function get representativeCategoryHierarchy():Array {
			return props.cat1_hierarchy;
		}
		/**
		 * Media's conceptual category hierarchy, requires a getData() call
		 * @see #getData()
		 */
		public function get conceptualCategoryHierarchy():Array {
			return props.cat2_hierarchy;
		}
	}
}