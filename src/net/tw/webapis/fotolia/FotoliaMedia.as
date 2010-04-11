package net.tw.webapis.fotolia {
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import net.tw.webapis.fotolia.abstract.FotoliaServiceRequester;
	import net.tw.webapis.fotolia.util.DataParser;
	
	import org.osflash.signals.Signal;
	/**
	 * Represents a Fotolia media.
	 */
	public class FotoliaMedia extends FotoliaServiceRequester {
		protected static var _serviceMediaDict:Dictionary=new Dictionary();
		//
		protected var _internalGotData:Signal=new Signal(Object);
		protected var _gotData:Signal=new Signal(FotoliaMedia);
		protected var _gotGalleries:Signal=new Signal(Array, FotoliaMedia);
		protected var _gotComp:Signal=new Signal(Object, FotoliaMedia);
		protected var _purchased:Signal=new Signal(String, FotoliaMedia);
		//
		protected var _fetchedData:Boolean=false;
		protected var _comp:Object;
		protected var _downloadURL:String;
		protected var _thumbnailURLs:Array=[];
		protected var _purchaseLicenseName:String;
		//
		public static const THUMBNAIL_SIZE_SMALL:uint=30;
		public static const THUMBNAIL_SIZE_MEDIUM:uint=110;
		public static const THUMBNAIL_SIZE_LARGE:uint=400;
		//
		public static const TYPE_PHOTO:uint=1;
		public static const TYPE_ILLUSTRATION:uint=2;
		public static const TYPE_VECTOR:uint=3;
		public static const TYPE_VIDEO:uint=4;
		//
		public static const LICENSE_XS:String='XS';
		public static const LICENSE_S:String='S';
		public static const LICENSE_M:String='M';
		public static const LICENSE_L:String='L';
		public static const LICENSE_XL:String='XL';
		public static const LICENSE_XXL:String='XXL';
		public static const LICENSE_XXXL:String='XXXL';
		//
		public static const LICENSE_NTSC:String='NTSC';
		public static const LICENSE_PAL:String='PAL';
		public static const LICENSE_HD780:String='HD780';
		public static const LICENSE_HD1080:String='HD1080';
		//
		public static const LICENSE_V:String='V';
		public static const LICENSE_VX:String='VX';
		//
		public static const LICENSE_X:String='X';
		//
		public static const VIDEO_LICENSE_PREFIX:String='V_';
		//
		public static const METHOD_GET_MEDIA_DATA:String='xmlrpc.getMediaData';
		public static const METHOD_GET_MEDIA_GALLERIES:String='xmlrpc.getMediaGalleries';
		public static const METHOD_GET_MEDIA_COMP:String='xmlrpc.getMediaComp';
		public static const METHOD_GET_MEDIA:String='xmlrpc.getMedia';
		//
		public static const LOCAL_FILENAME_PREFIX:String='fotolia_';
		public static const LOCAL_FILENAME_SEPARATOR:String='_';
		//
		/**
		 * @param	pService	Used for its API key and fault handler
		 * @param	pProps		Random properties to be passed-in
		 */
		public function FotoliaMedia(pService:FotoliaService, pProps:Object) {
			super(pService);
			mergeProps(pProps);
			_internalGotData.add(onGotData);
			gotComp.add(onCompGot);
			purchased.add(onPurchased);
		}
		public static function getFromProps(s:FotoliaService, p:Object):FotoliaMedia {
			var medias:Object;
			if (!_serviceMediaDict[s]) medias=_serviceMediaDict[s]={};
			else medias=_serviceMediaDict[s];
			//
			if (medias[p.id]) {
				medias[p.id].mergeProps(p);
				return medias[p.id];
			}
			var m:FotoliaMedia=new FotoliaMedia(s, p);
			medias[p.id]=m;
			return m;
		}
		public static function getFromID(s:FotoliaService, id:uint):FotoliaMedia {
			return getFromProps(s, {id:id});
		}
		override protected function mergeProps(o:Object):void {
			//trace(mx.utils.ObjectUtil.toString(o));
			super.mergeProps(o);
			if (o.hasOwnProperty('licenses')) {
				var licenses:Object={};
				for each(var l:Object in o.licenses) {
					licenses[fixLicenseName(l.name)]=l.price;
				}
				o.licenses=licenses;
			}
			// Let's clean those names, and store the raw values, just in case...
			if (o.hasOwnProperty('cat1_hierarchy')) {
				(o.cat1_hierarchy as Array).forEach(function(item:Object, index:int, ar:Array):void {
					o.cat1_hierarchy[index].rawName=item.name;
					o.cat1_hierarchy[index].name=FotoliaCategory.cleanName(item.name);
				});
			}
			if (o.hasOwnProperty('cat2_hierarchy')) {
				(o.cat2_hierarchy as Array).forEach(function(item:Object, index:int, ar:Array):void {
					o.cat2_hierarchy[index].rawName=item.name;
					o.cat2_hierarchy[index].name=FotoliaCategory.cleanName(item.name);
				});
			}
			if (o.hasOwnProperty('thumbnail_url')) {
				var tnSize:String=String(o.thumbnail_url).split(/\/([0-9]{2,3})_/)[1];
				_thumbnailURLs[int(tnSize)]=o.thumbnail_url;
			}
			super.mergeProps(o);
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
		 * Valid thumbnailSize values are FotoliaMedia.SIZE_SMALL, FotoliaMedia.SIZE_MEDIUM and FotoliaMedia.SIZE_LARGE.
		 * @param	thumbnailSize
		 * @param	langID
		 * @see		#gotData
		 * @see		http://us.fotolia.com/Services/API/Method/getMediaData
		 */
		public function getData(thumbnailSize:uint=110, langID:uint=0):void {
			loadRequest(
				METHOD_GET_MEDIA_DATA,
				[key, id, fixThumbnailSize(thumbnailSize), _service.autoPickLang(langID)],
				_internalGotData
			);
		}
		public static function fixThumbnailSize(size:uint):uint {
			if ([THUMBNAIL_SIZE_SMALL, THUMBNAIL_SIZE_MEDIUM, THUMBNAIL_SIZE_LARGE].indexOf(size)==-1) return THUMBNAIL_SIZE_MEDIUM;
			return size;
		}
		protected function onGotData(o:Object):void {
			mergeProps(o);
			_fetchedData=true;
			gotData.dispatch(this);
		}
		/**
		 * Will be true if a successful call to getData was made.
		 */
		public function get fetchedData():Boolean {
			return _fetchedData;
		}
		/**
		 * Signal dispacthed after a getGalleries call.
		 * Listeners will receive 2 arguments: an Array of FotoliaGallery objects, and the target FotoliaMedia.
		 * @see #getGalleries()
		 */
		public function get gotGalleries():Signal {
			return _gotGalleries;
		}
		/**
		 * Remote getGalleries call.
		 * @see #gotGalleries
		 */
		public function getGalleries(langID:uint=0, pThumbnailSize:uint=110):void {
			loadRequest(
				METHOD_GET_MEDIA_GALLERIES,
				[key, id, _service.autoPickLang(langID), pThumbnailSize],
				gotGalleries,
				DataParser.arrayToGalleries,
				[_service, this]
			);
		}
		/**
		 * Boolean indicating if this media has a comp file.
		 * Might return false if typeID hasn't been fetched yet!
		 */
		public function canGetComp():Boolean {
			return isPhoto() || isIllustration();
		}
		/**
		 * Signal dispacthed after a getComp call.
		 * Listeners will receive 2 arguments: an Object (with url:String, width:uint and height:uint properties), and the target FotoliaMedia.
		 */
		public function get gotComp():Signal {
			return _gotComp;
		}
		/**
		 * Remote getComp call.
		 * @see #gotComp
		 * @see http://us.fotolia.com/Services/API/Method/getMediaComp
		 */
		public function getComp():Boolean {
			if (!canGetComp()) return false;
			loadRequest(
				METHOD_GET_MEDIA_COMP,
				[key, id],
				gotComp,
				DataParser.rawObjectTargetHandler,
				[this]
			);
			return true;
		}
		protected function onCompGot(o:Object, tg:FotoliaMedia):void {
			_comp=o;
		}
		public function get comp():Object {
			return _comp;
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
			//licenseName=FotoliaMedia.fixLicenseName(this, licenseName);
			_purchaseLicenseName=licenseName;
			loadRequest(
				METHOD_GET_MEDIA,
				[key, sessionID, id, licenseName],
				purchased,
				DataParser.purchaseHandler,
				[this]
			);
		}
		public function get purchaseLicenseName():String {
			return _purchaseLicenseName;
		}
		protected function onPurchased(u:String, th:FotoliaMedia):void {
			_downloadURL=u;
		}
		public function get downloadURL():String {
			return _downloadURL;
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
		 * Media's latest thumbnail size, requires a getData call for a FotoliaCartMedia.
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get thumbnailSize():Point {
			return new Point(props.thumbnail_width, props.thumbnail_height);
		}
		/**
		 * Checks if the thumbnail URL for the given size has been fetched yet.
		 * @see	#getData()
		 * @see #thumbnailURL
		 */
		public function hasThumbnailURL(size:uint):Boolean {
			return Boolean(_thumbnailURLs[size]);
		}
		/**
		 * Media's latest thumbnail URL, requires a getData call for a FotoliaCartMedia.
		 * @see #getData()
		 * @see #getThumbnailURL()
		 * @see FotoliaCartMedia
		 */
		public function get thumbnailURL():String {
			return props.thumbnail_url;
		}
		/**
		 * Media's thumbnail URL for a given size. Valid values are FotoliaMedia.SIZE_SMALL, FotoliaMedia.SIZE_MEDIUM and FotoliaMedia.SIZE_LARGE.
		 * Might require a getData call with the appropriate size.
		 * @see #thumbnailURL
		 * @see #getData()
		 */
		public function getThumbnailURL(size:uint):String {
			if (!hasThumbnailURL(size)) return null;
			return _thumbnailURLs[size];
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
		 * Media's available licenses, requires a getData call for a FotoliaCartMedia.
		 * The Object has as many properties as available licenses for this media, their name will be the license name and their value will be the price of that license.
		 * @see #getData()
		 * @see FotoliaCartMedia
		 */
		public function get licenses():Object {
			return props.licenses;
		}
		public function fixLicenseName(s:String):String {
			if (isVideo() && s.substr(0, VIDEO_LICENSE_PREFIX.length)!=VIDEO_LICENSE_PREFIX) return VIDEO_LICENSE_PREFIX+s;
			return s;
		}
		public static function stripLicensePrefix(licenseName:String):String {
			return licenseName.indexOf(VIDEO_LICENSE_PREFIX)==0 ? licenseName.substr(VIDEO_LICENSE_PREFIX.length) : licenseName;
		}
		/**
		 * Checks if this media is available for a given license, might require a getData call.
		 * @see #licenses
		 */
		public function hasLicense(licenseName:String):Boolean {
			return licenses && licenses.hasOwnProperty(fixLicenseName(licenseName));
		}
		/**
		 * Checks if enough data has been fetched to get this media's licenses' details.
		 * @see #licensesDetails
		 */
		public function hasLicenseDetails(licenseName:String):Boolean {
			return licensesDetails && licensesDetails.hasOwnProperty(fixLicenseName(licenseName));
		}
		/**
		 * Returns the price for a given license.
		 * @return	The price for a given license. -1 if the license is not available, or if not enought data has been fetched.
		 * @see		#licenses
		 */
		public function getLicensePrice(licenseName:String):int {
			if (!hasLicense(licenseName)) return -1;
			return licenses[fixLicenseName(licenseName)];
		}
		/**
		 * Returns the details for a given license.
		 * @return	The details for a given license. null if the license is not available, or if not enought data has been fetched.
		 * @see		#licensesDetails
		 */
		public function getLicenseDetails(licenseName:String):* {
			if (!hasLicenseDetails(licenseName)) return null;
			return licensesDetails[fixLicenseName(licenseName)];
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
		 * Media's licenses details, in an Array, with additional nbCredits property, sorted by credits.
		 * @see #licensesDetails
		 */
		public function get licensesDetailsArray():Array {
			var a:Array=[];
			var license:Object;
			for each(license in licensesDetails) {
				license.nbCredits=getLicensePrice(license.license_name);
				a.push(license);
			}
			a.sortOn('nbCredits', Array.NUMERIC);
			return a;
		}
		/**
		 * Media's licenses names and nbCredits in an Array, sorted by credits.
		 * @see #licenses
		 */
		public function get licensesArray():Array {
			var a:Array=[];
			var licenseName:String;
			for (licenseName in licenses) {
				a.push({name:stripLicensePrefix(licenseName), nbCredits:licenses[licenseName]});
			}
			a.sortOn('nbCredits', Array.NUMERIC);
			return a;
		}
		/**
		 * Media's available license names in an Array, sorted by credits.
		 * @see #licenses
		 */
		public function get licensesScreenNames():Array {
			var a:Array=licensesArray;
			for (var i:int=0; i<a.length; i++) {
				a[i]=a[i].name;
			}
			return a;
		}
		/**
		 * Media's representative category, requires a getData() call.
		 * @see #getData()
		 */
		public function get representativeCategory():Object {
			return FotoliaCategory.cleanName(props.cat1);
		}
		/**
		 * Media's conceptual category, requires a getData() call.
		 * @see #getData()
		 */
		public function get conceptualCategory():Object {
			return FotoliaCategory.cleanName(props.cat2);
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
		 * Media's preview FLV URL, only valid for videos, might require a getData call.
		 * @see #getData()
		 */
		public function get flvURL():String {
			return props.flv_url;
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
		/**
		 * Indicates if this media is a video.
		 * @see #TYPE_VIDEO
		 */
		public function isVideo():Boolean {
			return typeID==TYPE_VIDEO;
		}
		public function get extension():String {
			if (isPhoto() || isIllustration()) return 'jpg';
			//if (isVector()) return 'xxx';
			return 'xxx';
		}
		public function getLocalCompFileName():String {
			return LOCAL_FILENAME_PREFIX+id+'.'+extension;
		}
		public function getLocalFileName(licenseName:String):String {
			return LOCAL_FILENAME_PREFIX+id+LOCAL_FILENAME_SEPARATOR+licenseName+'.'+extension;
		}
		public function getPurchaseLocalFileName():String {
			return getLocalFileName(purchaseLicenseName);
		}
		public static function fileNameMatchesLocalMedia(s:String):Boolean {
			return extractMediaIDFromLocalMedia(s)!=0;
		}
		public static function extractMediaIDFromLocalMedia(s:String):uint {
			if (s.indexOf(LOCAL_FILENAME_PREFIX)!=0) return 0;
			var fn:String=s.split('.')[0];
			var parts:Array=fn.replace(LOCAL_FILENAME_PREFIX, '').split(LOCAL_FILENAME_SEPARATOR);
			var matches:Array=String(parts[0]).match(/^[0-9]+$/);
			if (!matches) return 0;
			return uint(matches[0]);
		}
	}
}