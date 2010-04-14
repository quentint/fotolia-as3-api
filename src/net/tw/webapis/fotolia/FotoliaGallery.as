package net.tw.webapis.fotolia {
	import flash.geom.Point;
	import net.tw.webapis.fotolia.abstract.AbstractFotoliaGallery;
	import net.tw.webapis.fotolia.util.DataParser;
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
		 * Remote getMedias call.
		 * @param	params
		 * @see		#gotMedias
		 * @see		http://us.fotolia.com/Services/API/Method/getSearchResults
		 */
		public function getMedias(params:Object=null):void {
			if (!params) params={};
			params.gallery_id=id;
			params.language_id=_service.autoPickLang(params.language_id);
			//
			loadRequest(
				FotoliaService.METHOD_GET_SEARCH_RESULTS,
				[key, params],
				gotMedias,
				DataParser.objectToSearchResults,
				[_service]
			);
		}
		/**
		 * Gallery's thumbnail URL.
		 */
		public function get thumbnailURL():String {
			return props.thumbnail_url;
		}
		public function get largeThumbnailURL():String {
			if (!thumbnailURL) return null;
			return FotoliaMedia.computeMediumThumbnailURLToLarge(thumbnailURL);
		}
		/**
		 * Gallery's thumbnail size.
		 */
		public function get thumbnailSize():Point {
			return new Point(props.thumbnail_width, props.thumbnail_height);
		}
		/**
		 * Gallery's URL on Fotolia's site.
		 */
		override public function get url():String {
			return FotoliaService.BASE_URL+'Galleries/'+id;
		}
	}
}