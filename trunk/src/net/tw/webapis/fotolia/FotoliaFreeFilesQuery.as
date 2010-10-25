package net.tw.webapis.fotolia {
	public class FotoliaFreeFilesQuery {
		public var thumbnailSize:uint=FotoliaMedia.THUMBNAIL_SIZE_MEDIUM;
		public var langID:uint;
		public var details:Boolean;
		public var offset:uint=0;
		public var limit:uint=FotoliaService.SEARCH_DEFAULT_LIMIT;
	}
}