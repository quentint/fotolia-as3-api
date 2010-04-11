package net.tw.webapis.fotolia {
	import net.tw.webapis.fotolia.abstract.AbstractFotoliaGallery;
	import org.osflash.signals.Signal;
	import net.tw.webapis.fotolia.util.DataParser;
	/**
	 * Represents a private (user) Fotolia gallery.
	 */
	public class FotoliaUserGallery extends AbstractFotoliaGallery {
		protected var _user:FotoliaUser;
		//
		protected var _disposed:Signal=new Signal(FotoliaUserGallery);
		protected var _addedMedia:Signal=new Signal(FotoliaUserGallery);
		protected var _removedMedia:Signal=new Signal(FotoliaUserGallery);
		//
		public static const METHOD_DELETE_USER_GALLERY:String='xmlrpc.deleteUserGallery';
		public static const METHOD_ADD_TO_USER_GALLERY:String='xmlrpc.addToUserGallery';
		public static const METHOD_REMOVE_FROM_USER_GALLERY:String='xmlrpc.removeFromUserGallery';
		public static const METHOD_GET_USER_GALLERY_MEDIAS:String='xmlrpc.getUserGalleryMedias';
		//
		public static const TO_MODERATE_GALLERY_NAME:String='To moderate';
		/**
		 * @param	pService	Used for its API key and fault handler
		 * @param	props		Random properties to be passed-in
		 * @param	pUser		Owner of the gallery
		 */
		public function FotoliaUserGallery(pService:FotoliaService, props:Object, pUser:FotoliaUser) {
			super(pService, props);
			_user=pUser;
		}
		/**
		 * Owner of the gallery.
		 */
		public function get user():FotoliaUser {
			return _user;
		}
		/**
		 * Boolean indicating if this gallery is the user's Lightbox.
		 */
		public function isLightbox():Boolean {
			return rawName=='';
		}
		/**
		 * Boolean indicating if this gallery is the "To moderate" one.
		 */
		public function isToModerate():Boolean {
			return name==TO_MODERATE_GALLERY_NAME;
		}
		/**
		 * Boolean indicating if this gallery is supposed to be removed (disposed).
		 * @see #dispose()
		 */
		public function isDisposable():Boolean {
			return !isLightbox() && !isToModerate();
		}
		/**
		 * This user gallery's URL on Fotolia's site.
		 */
		override public function get url():String {
			return FotoliaService.BASE_URL+'Lightbox'+(isLightbox() ? '' : '/'+id);
		}
		/**
		 * Either returns the gallery's name, or 'Lightbox'.
		 * @see #rawName
		 */
		override public function get name():String {
			return isLightbox() ? 'Lightbox' : rawName;
		}
		/**
		 * Returns the gallery's name, could be an empty String (Lightbox).
		 * @see #name
		 */
		public function get rawName():String {
			return super.name;
		}
		/**
		 * Signal dispatched after a dispose call.
		 * Listeners will receive 1 argument: the target FotoliaUserGallery.
		 * @see #dispose()
		 */
		public function get disposed():Signal {
			return _disposed;
		}
		/**
		 * Remote dispose call.
		 * @see #disposed
		 * @see http://us.fotolia.com/Services/API/Method/deleteUserGallery
		 */
		public function dispose():void {
			loadRequest(
				METHOD_DELETE_USER_GALLERY,
				[key, user.sessionID, id],
				disposed,
				DataParser.targetHandler,
				[this]
			);
		}
		/**
		 * Signal dispatched after an addMedia call.
		 * Listeners will receive 1 argument: the target FotoliaUserGallery.
		 * @see #addMedia()
		 */
		public function get addedMedia():Signal {
			return _addedMedia;
		}
		/**
		 * Remote addMedia call.
		 * @param	mediaID
		 * @see		#addedMedia
		 * @see		http://us.fotolia.com/Services/API/Method/addToUserGallery
		 */
		public function addMedia(mediaID:uint):void {
			loadRequest(
				METHOD_ADD_TO_USER_GALLERY,
				[key, user.sessionID, mediaID, id],
				addedMedia,
				DataParser.targetHandler,
				[this]
			);
		}
		/**
		 * Signal dispatched after a removeMedia call.
		 * Listeners will receive 1 argument: the target FotoliaUserGallery.
		 * @see #removeMedia()
		 */
		public function get removedMedia():Signal {
			return _removedMedia;
		}
		/**
		 * Remote removeMedia call.
		 * @param	mediaID
		 * @see		#removedMedia
		 * @see		http://us.fotolia.com/Services/API/Method/removeFromUserGallery
		 */
		public function removeMedia(mediaID:uint):void {
			loadRequest(
				METHOD_REMOVE_FROM_USER_GALLERY,
				[key, user.sessionID, mediaID, id],
				removedMedia,
				DataParser.targetHandler,
				[this]
			);
		}
		/**
		 * Remote getMedias call.
		 * @see		#gotMedias
		 * @see		http://us.fotolia.com/Services/API/Method/getUserGalleryMedias
		 */
		public function getMedias(pageIndex:uint=0, nbPerPage:uint=32, thumbnailSize:uint=110, detailLevel:uint=0):void {
			nbPerPage--;//Bug API!
			//trace((pageIndex-1)/**nbPerPage*/, nbPerPage);
			loadRequest(
				FotoliaUserGallery.METHOD_GET_USER_GALLERY_MEDIAS,
				[key, user.sessionID, (pageIndex-1)*nbPerPage, nbPerPage, thumbnailSize, id, detailLevel],
				gotMedias,
				DataParser.objectToSearchResults,
				[_service]
			);
		}
	}
}