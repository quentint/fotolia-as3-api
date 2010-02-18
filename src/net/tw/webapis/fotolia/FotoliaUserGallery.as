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
			return name=='';
		}
		/**
		 * This user gallery's URL on Fotolia's site.
		 */
		public function get url():String {
			return FotoliaService.BASE_URL+'Lightbox'+(isLightbox() ? '' : '/'+id);
		}
		/**
		 * Either returns the gallery's name, or 'Lightbox'.
		 */
		public function get safeName():String {
			return isLightbox() ? 'Lightbox' : name;
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
		 * @see #addMedia
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
		 * @see #removeMedia
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
	}
}