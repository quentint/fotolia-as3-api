package net.tw.webapis.fotolia {
	/**
	 * Represents a Fotolia media in a user's shopping cart.
	 */
	public class FotoliaCartMedia extends FotoliaMedia {
		protected var _licenceName:String;
		/**
		 * @param	pService
		 * @param	pProps
		 * @param	pLicenceName	The licence name to be used when purchasing
		 * @see		FotoliaMedia
		 * @see		FotoliaShoppingCart
		 */
		public function FotoliaCartMedia(pService:FotoliaService, pProps:Object, pLicenceName:String) {
			super(pService, pProps);
			_licenceName=pLicenceName;
		}
		public function get licenceName():String {
			return _licenceName;
		}
	}
}