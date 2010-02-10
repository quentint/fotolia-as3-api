package net.tw.webapis.fotolia {
	import flash.geom.Point;
	import net.tw.webapis.fotolia.abstract.AbstractFotoliaGallery;
	/**
	 * Represents a public Fotolia gallery.
	 */
	public class FotoliaGallery extends AbstractFotoliaGallery {
		/**
		 * @param	pService	Used for its API key and fault handler
		 * @param	pProps		Random properties to be passed-in
		 */
		public function FotoliaGallery(pService:FotoliaService, pProps:Object) {
			super(pService, props);
			_props=pProps;
		}
		/**
		 * Gallery's thumbnail URL.
		 */
		public function get thumbnailURL():String {
			return props.thumbnail_url;
		}
		/**
		 * Gallery's thumbnail size.
		 */
		public function get thumbnailSize():Point {
			return new Point(props.thumbnail_width, props.thumbnail_height);
		}
	}
}