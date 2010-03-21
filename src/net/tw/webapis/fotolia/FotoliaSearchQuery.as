package net.tw.webapis.fotolia {
	[RemoteClass(alias="net.tw.webapis.fotolia.FotoliaSearchQuery")]
	public class FotoliaSearchQuery {
		public var words:String;
		public var langID:uint;
		public var offset:uint=0;
		public var limit:uint=FotoliaService.SEARCH_DEFAULT_LIMIT;
		public var filterPhoto:Boolean;
		public var filterIllustration:Boolean;
		public var filterVector:Boolean;
		public var filterVideo:Boolean;
		public var filterOffensive:Boolean;
		public var filterIsolated:Boolean;
		public var filterPanoramic:Boolean;
		public var filterLicenseL:Boolean;
		public var filterLicenseXL:Boolean;
		public var filterLicenseXXL:Boolean;
		public var filterLicenseX:Boolean;
		public var filterLicenseE:Boolean;
		public var filterOrientation:String;
		public var order:String=FotoliaService.SEARCH_ORDER_RELEVANCE;
		public var thumbnailSize:uint=FotoliaMedia.THUMBNAIL_SIZE_MEDIUM;
		public var details:Boolean;
		public function FotoliaSearchQuery(pWords:String='') {
			words=pWords;
		}
		public function get searchParams():Object {
			var o:Object={};
			o.words=words;
			o.offset=offset;
			o.limit=Math.min(limit, FotoliaService.SEARCH_MAX_LIMIT);
			o.order=order;
			//
			var filters:Object={};
			if (filterOrientation)		filters['orientation']=1;
			if (filterPanoramic)		filters['panoramic:on']=1;
			if (filterIsolated)			filters['isolated:on']=1;
			//
			if (filterPhoto)			filters['content_type:photo']=1;
			if (filterIllustration)		filters['content_type:illustration']=1;
			if (filterVector)			filters['content_type:vector']=1;
			if (filterVideo)			filters['content_type:video']=1;
			//
			if (filterLicenseL)			filters['license_L:on']=1;
			if (filterLicenseXL)		filters['license_XL:on']=1;
			if (filterLicenseXXL)		filters['license_XXL:on']=1;
			if (filterLicenseX)			filters['license_X:on']=1;
			if (filterLicenseE)			filters['license_E:on']=1;
			//
			if (filterOffensive)		filters['offensive:2']=1;
			o.filters=filters;
			//
			o.thumbnail_size=FotoliaMedia.fixThumbnailSize(thumbnailSize);
			if (details) o.detail_level=1;
			//
			return o;
		}
	}
}