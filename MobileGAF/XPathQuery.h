/**
 *
 Returns arrays of nodes comprised of this dictionary.
 
 Credit goes to: http://cocoawithlove.com/2008/10/using-libxml2-for-parsing-and-xpath.html
 
 nodeName — an NSString containing the name of the node
 nodeContent — an NSString containing the textual content of the node
 nodeAttributeArray — an NSArray of NSDictionary where each dictionary has two keys: attributeName (NSString) and nodeContent (NSString)
 nodeChildArray — an NSArray of child nodes (same structure as this node)
 
 */

#define XPATH_STRING_ENCODING NSISOLatin1StringEncoding

NSArray *PerformHTMLXPathQuery(NSData *document, NSString *query);
NSArray *PerformXMLXPathQuery(NSData *document, NSString *query);
NSArray *PerformHTMLXPathQueryForTags(NSData *document, NSString *query);