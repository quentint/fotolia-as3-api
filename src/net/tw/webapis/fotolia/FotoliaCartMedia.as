package net.tw.webapis.fotolia {
	/**
	 * Represents a Fotolia media in a user's shopping cart.
	 */
	public class FotoliaCartMedia {
		protected var _media:FotoliaMedia
		protected var _licenseName:String;
		/**
		 * @param	pService
		 * @param	pProps
		 * @param	pLicenseName	The license name to be used when purchasing
		 * @see		FotoliaMedia
		 * @see		FotoliaShoppingCart
		 */
		public function FotoliaCartMedia(pService:FotoliaService, pProps:Object, pLicenseName:String) {
			_media=FotoliaMedia.getFromProps(pService, pProps);
			_licenseName=pLicenseName;
		}
		public function get licenseName():String {
			return _licenseName;
		}
		public function isSubscription():Boolean {
			return licenseName.indexOf(FotoliaMedia.SUBSCRIPTION_LICENSE_PREFIX)==0;
		}
		public function get screenLicenseName():String {
			var ln:String=licenseName;
			if (isSubscription()) ln=ln.replace(FotoliaMedia.SUBSCRIPTION_LICENSE_PREFIX, '');
			return ln.substr(0, FotoliaMedia.VIDEO_LICENSE_PREFIX.length)==FotoliaMedia.VIDEO_LICENSE_PREFIX ? licenseName.substr(FotoliaMedia.VIDEO_LICENSE_PREFIX.length) : licenseName;
		}
		public function get media():FotoliaMedia {
			return _media;
		}
	}
}