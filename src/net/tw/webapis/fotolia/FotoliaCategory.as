package net.tw.webapis.fotolia {
	import net.tw.webapis.fotolia.abstract.FotoliaServiceRequester;
	import org.osflash.signals.Signal;
	import net.tw.webapis.fotolia.util.DataParser;
	/**
	 * Represents a Fotolia category.
	 */
	public class FotoliaCategory extends FotoliaServiceRequester {
		public static const TYPE_REPRESENTATIVE:uint=1;
		public static const TYPE_CONCEPTUAL:uint=2;
		//
		public static const METHOD_GET_CATEGORIES_REPRESENTATIVE:String='xmlrpc.getCategories1';
		public static const METHOD_GET_CATEGORIES_CONCEPTUAL:String='xmlrpc.getCategories2';
		//
		protected var _type:uint;
		protected var _langID:uint;
		protected var _parent:FotoliaCategory;
		protected var _categories:Array=[];
		protected var _fetchedCategories:Boolean=false;
		//
		protected var _gotCategories:Signal=new Signal(Array, FotoliaCategory);
		/**
		 * @param	pService	Used for its API key and fault handler
		 * @param	pProps		Random properties to be passed-in
		 * @param	pType		Can be either 1 (Representative) or 2 (Conceptual)
		 * @param	pLangID
		 * @param	pParent		The parent FotoliaCategory
		 */
		public function FotoliaCategory(pService:FotoliaService, pProps:Object, pType:uint, pLangID:uint=0, pParent:FotoliaCategory=null) {
			super(pService);
			_props=pProps;
			_type=pType;
			_langID=_service.autoPickLang(pLangID);
			_parent=pParent;
			gotCategories.add(onCategoriesGot);
		}
		/**
		 * Parent category
		 */
		public function get parent():FotoliaCategory {
			return _parent;
		}
		/**
		 * Boolean indicating if this category is a root one.
		 */
		public function isAtRoot():Boolean {
			return !_parent;
		}
		/**
		 * Boolean indicating if this category is a leaf one (so cannot have any sub-categories).
		 */
		public function isLeaf():Boolean {
			return props.nb_sub_categories==0;
		}
		/**
		 * Category type. Can be either 1 (Representative) or 2 (Conceptual).
		 */
		public function get type():uint {
			return _type;
		}
		/**
		 * Boolean indicating if this category is a representative one.
		 */
		public function isRepresentative():Boolean {
			return type==TYPE_REPRESENTATIVE;
		}
		/**
		 * Boolean indicating if this category is a conceptual one.
		 */
		public function isConceptual():Boolean {
			return type==TYPE_CONCEPTUAL;
		}
		/**
		 * Category's language ID.
		 * @see FotoliaService
		 */
		public function get langID():uint {
			return _langID;
		}
		/**
		 * Category's name as received from the API, could contain some HTML entities.
		 * @see #name
		 */
		public function get rawName():String {
			return props.name;
		}
		/**
		 * Category's name, without HTML entities.
		 * @see #rawName
		 */
		public function get name():String {
			return rawName.replace('&amp;', '&');
		}
		/**
		 * Category's ID
		 */
		public function get id():uint {
			return props.id;
		}
		/**
		 * Returns this category's URL on Fotolia's site.
		 */
		public function get url():String {
			return FotoliaService.BASE_URL+'cat'+type+'/'+id;
		}
		/**
		 * Utility method to get a category method's name from a category type ID.
		 * @param	type
		 * @return	The method name to use for the given type
		 */
		public static function getCategoryMethod(type:uint):String {
			return type==FotoliaCategory.TYPE_REPRESENTATIVE ? METHOD_GET_CATEGORIES_REPRESENTATIVE : METHOD_GET_CATEGORIES_CONCEPTUAL;
		}
		/**
		 * Signal dispatched after a getCategories call.
		 * Listeners will receive 2 arguments: an Array of FotoliaCatory objects and the target FotoliaCategory, the array will also be available via the categories property.
		 * @see #getCategories()
		 * @see #categories
		 */
		public function get gotCategories():Signal {
			return _gotCategories;
		}
		/**
		 * Remote getCategories call.
		 * @param	pLangID
		 * @see #gotCategories
		 * @see http://us.fotolia.com/Services/API/Method/getCategories1
		 * @see http://us.fotolia.com/Services/API/Method/getCategories2
		 */
		public function getCategories(pLangID:uint=0):void {
			var lid:uint=pLangID>0 ? pLangID : langID;
			loadRequest(
				getCategoryMethod(type),
				[key, lid, id],
				gotCategories,
				DataParser.objectToCategories,
				[_service, type, lid, this]
			);
		}
		protected function onCategoriesGot(a:Array, c:FotoliaCategory):void {
			_categories=a;
			_fetchedCategories=true;
		}
		/**
		 * Returns an Array of sub-categories for this category, if any.
		 * @see #getCategories()
		 */
		public function get categories():Array {
			return _categories;
		}
		/**
		 * Boolean indicating if sub-galleries have been fetched.
		 */
		public function fetchedCategories():Boolean {
			return _fetchedCategories;
		}
	}
}