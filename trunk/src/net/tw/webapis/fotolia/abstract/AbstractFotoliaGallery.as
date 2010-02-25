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
		protected var _lastResults:FotoliaSearchResults;
		/**
		 * @param	pService	Used for its API key and fault handler
		 * @param	pProps		Random properties to be passed-in
		 */
		public function AbstractFotoliaGallery(pService:FotoliaService, pProps:Object) {
			super(pService);
			_props=pProps;
			gotMedias.add(onMediasGot);
		}
		/**
		 * The gallery's ID
		 */
		public function get id():String {
			return props.id;
		}
		/**
		 * The gallery's name.
		 */
		public function get name():String {
			return props.name;
		}
		/**
		 * The gallery's number of medias.
		 */
		public function get nbMedia():uint {
			return props.nb_media;
		}
		/**
		 * Fetched gallery medias.
		 * A FotoliaSearchResults object.
		 * @see #getMedias()
		 */
		public function get lastResults():FotoliaSearchResults {
			return _lastResults;
		}
		/**
		 * Signal dispatched after a getMedias call.
		 * Listeners will receive 1 argument: a FotoliaSearchResults object.
		 * @see #getMedias()
		 * @see FotoliaSearchResults
		 */
		public function get gotMedias():Signal {
			return _gotMedias;
		}
		protected function onMediasGot(sr:FotoliaSearchResults):void {
			_lastResults=sr;
			props.nb_media=sr.nbResults;
		}
		public function get url():String {
			return '';
		}
	}
}