package net.tw.webapis.fotolia.abstract {
	import net.tw.webapis.fotolia.FotoliaService;
	import org.osflash.signals.Signal;
	import net.tw.webapis.fotolia.util.DataParser;
	import net.tw.webapis.fotolia.FotoliaSearchResults;
	/**
	 * Abstract class to handle common gallery actions.
	 * @see FotoliaGallery
	 * @see	FotoliaUserGallery
	 */
	public class AbstractFotoliaGallery extends FotoliaServiceRequester {
		protected var _gotMedias:Signal=new Signal(FotoliaSearchResults);
		/**
		 * @param	pService	Used for its API key and fault handler
		 * @param	pProps		Random properties to be passed-in
		 */
		public function AbstractFotoliaGallery(pService:FotoliaService, pProps:Object) {
			super(pService);
			_props=pProps;
		}
		/**
		 * The gallery's ID
		 */
		public function get id():String {
			return props.id;
		}
		/**
		 * The gallery's name
		 */
		public function get name():String {
			return props.name;
		}
		/**
		 * The gallery's number of medias
		 */
		public function get nbMedia():uint {
			return props.nb_media;
		}
		/**
		 * Signal dispatched after a getMedias call
		 * Listeners will receive 1 argument: a FotoliaSearchResults object
		 * @see #getMedias()
		 * @see FotoliaSearchResults
		 */
		public function get gotMedias():Signal {
			return _gotMedias;
		}
		/**
		 * Remote getMedias call
		 * @param	params
		 * @see		#gotMedias
		 * @see		http://us.fotolia.com/Services/API/Method/getUserGalleryMedias
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
	}
}