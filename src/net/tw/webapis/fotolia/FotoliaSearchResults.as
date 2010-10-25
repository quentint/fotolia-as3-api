package net.tw.webapis.fotolia {
	/**
	 * Represent Fotolia search results.
	 */
	public class FotoliaSearchResults {
		protected var _nbResults:uint;
		protected var _medias:Array;
		//
		public function FotoliaSearchResults(pNbResults:uint, pMedias:Array) {
			_nbResults=pNbResults;
			_medias=pMedias;
		}
		/**
		 * Total number of search results.
		 */
		public function get nbResults():uint {
			return _nbResults ? _nbResults : (medias ? medias.length : 0);
		}
		/**
		 * Found medias. This Array only contains FotoliaMedia objects.
		 */
		public function get medias():Array {
			return _medias;
		}
	}
}