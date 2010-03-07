package net.tw.webapis.fotolia {
	import net.tw.webapis.fotolia.abstract.FotoliaServiceRequester;
	import org.osflash.signals.Signal;
	import net.tw.webapis.fotolia.util.DataParser;
	/**
	 * Represents a Fotolia user's shopping cart.
	 */
	public class FotoliaShoppingCart extends FotoliaServiceRequester {
		protected var _user:FotoliaUser;
		protected var _medias:Array=[];
		//
		protected var _internalGotList:Signal=new Signal();
		protected var _gotList:Signal=new Signal(Array, FotoliaShoppingCart);
		protected var _addedMedia:Signal=new Signal(FotoliaShoppingCart);
		protected var _removedMedia:Signal=new Signal(FotoliaShoppingCart);
		protected var _cleared:Signal=new Signal(FotoliaShoppingCart);
		protected var _transferredToLightBox:Signal=new Signal(FotoliaShoppingCart);
		protected var _updated:Signal=new Signal(FotoliaShoppingCart);
		//
		public static const METHOD_SHOPPING_CART_GET_LIST:String='shoppingcart.getList';
		public static const METHOD_SHOPPING_CART_ADD:String='shoppingcart.add';
		public static const METHOD_SHOPPING_CART_REMOVE:String='shoppingcart.remove';
		public static const METHOD_SHOPPING_CART_CLEAR:String='shoppingcart.clear';
		public static const METHOD_SHOPPING_CART_TRANSFER_TO_LIGHTBOX:String='shoppingcart.transferToLightbox';
		public static const METHOD_SHOPPING_CART_UPDATE:String='shoppingcart.update';
		/**
		 * @param	pService	Used for its API key and fault handler
		 * @param	pUser		The user linked to this shopping cart
		 */
		public function FotoliaShoppingCart(pService:FotoliaService, pUser:FotoliaUser) {
			super(pService);
			_user=pUser;
			_internalGotList.add(onListGot);
			//
			cleared.add(onCleared);
			transferredToLightbox.add(onCleared);
		}
		/**
		 * The user linked to this shopping cart.
		 */
		public function get user():FotoliaUser {
			return _user;
		}
		/**
		 * Signal dispatched after a getList call.
		 * Listeners will receive 2 arguments: an Array of FotoliaCartMedia and the target FotoliaShoppingCart.
		 * The FotoliaCartMedia Array will then be available throught the medias property.
		 * @see FotoliaCartMedia
		 * @see #getList()
		 * @see #medias
		 */
		public function get gotList():Signal {
			return _gotList;
		}
		/**
		 * Remote getList call.
		 * @see #gotList
		 * @see http://us.fotolia.com/Services/API/Method/shoppingcart_getList
		 */
		public function getList():void {
			loadRequest(
				METHOD_SHOPPING_CART_GET_LIST,
				[key, user.sessionID],
				_internalGotList
			);
		}
		protected function onListGot(o:Object):void {
			var contents:Object=o.contents;
			_medias=[];
			for (var id:String in contents) {
				_medias.push(new FotoliaCartMedia(_service, {id:uint(id)}, contents[id]));
			}
			gotList.dispatch(_medias, this);
		}
		/**
		 * Fetched shopping cart medias.
		 * This Array will NOT be updated after addMedia and removeMedia calls!
		 * @return	An Array of FotoliaCartMedia.
		 * @see		#getMedias()
		 */
		public function get medias():Array {
			return _medias;
		}
		/**
		 * Signal dispatched after an addMedia call.
		 * Listeners will receive 1 argument: the target FotoliaShoppingCart.
		 * @see #addMedia()
		 */
		public function get addedMedia():Signal {
			return _addedMedia;
		}
		/**
		 * Remote addMedia call.
		 * @param	mediaID
		 * @param	licenseName
		 * @see		#addedMedia
		 * @see		http://us.fotolia.com/Services/API/Method/shoppingcart_add
		 */
		public function addMedia(mediaID:uint, licenseName:String):void {
			loadRequest(
				METHOD_SHOPPING_CART_ADD,
				[key, user.sessionID, mediaID, licenseName],
				addedMedia,
				DataParser.targetHandler,
				[this]
			);
		}
		/**
		 * Signal dispatched after a removeMedia call.
		 * Listeners will receive 1 argument: the target FotoliaShoppingCart.
		 * @see #removeMedia()
		 */
		public function get removedMedia():Signal {
			return _removedMedia;
		}
		/**
		 * Remote removeMedia call.
		 * @param	mediaID
		 * @throws	ArgumentError
		 * @see		#removedMedia
		 * @see		http://us.fotolia.com/Services/API/Method/shoppingcart_remove
		 */
		public function removeMedia(mediaID:*):void {
			if (!(mediaID is uint) && !(mediaID is Array)) {
				throw new ArgumentError('removeMedia only accepts uint and Array values');
				return;
			}
			loadRequest(
				METHOD_SHOPPING_CART_REMOVE,
				[key, user.sessionID, mediaID],
				removedMedia,
				DataParser.targetHandler,
				[this]
			);
		}
		/**
		 * Signal dispatched after a clear call.
		 * Listeners will receive 1 argument: the target FotoliaShoppingCart.
		 * @see #clear()
		 */
		public function get cleared():Signal {
			return _cleared;
		}
		/**
		 * Remote clear call.
		 * @see #cleared
		 * @see http://us.fotolia.com/Services/API/Method/shoppingcart_clear
		 */
		public function clear():void {
			loadRequest(
				METHOD_SHOPPING_CART_CLEAR,
				[key, user.sessionID],
				cleared,
				DataParser.targetHandler,
				[this]
			);
		}
		protected function onCleared(sc:FotoliaShoppingCart):void {
			_medias=[];
		}
		/**
		 * Signal dispatched after a transferToLightbox call.
		 * Listeners will receive 1 argument: the target FotoliaShoppingCart.
		 * @see #transferToLightbox()
		 */
		public function get transferredToLightbox():Signal {
			return _transferredToLightBox;
		}
		/**
		 * Remote transferToLightbox call
		 * @param	mediaID
		 * @throws	ArgumentError
		 * @see		#transferredToLoghtbox
		 * @see		http://us.fotolia.com/Services/API/Method/shoppingcart_transferToLightbox
		 */
		public function transferToLightbox(mediaID:*):void {
			if (!(mediaID is uint) && !(mediaID is Array)) {
				throw new ArgumentError('transferToLightbox only accepts uint and Array values');
				return;
			}
			loadRequest(
				METHOD_SHOPPING_CART_TRANSFER_TO_LIGHTBOX,
				[key, user.sessionID, mediaID],
				transferredToLightbox,
				DataParser.targetHandler,
				[this]
			);
		}
		/**
		 * Signal dispatched after an update call.
		 * Listeners will receive 1 argument: the target FotoliaShoppingCart.
		 * @see #update()
		 */
		public function get updated():Signal {
			return _updated;
		}
		/**
		 * Remote update call.
		 * @see #updated
		 * @see http://us.fotolia.com/Services/API/Method/shoppingcart_update
		 */
		public function update(mediaID:uint, licenseName:String):void {
			loadRequest(
				METHOD_SHOPPING_CART_UPDATE,
				[key, user.sessionID, mediaID, licenseName],
				updated,
				DataParser.targetHandler,
				[this]
			);
		}
	}
}