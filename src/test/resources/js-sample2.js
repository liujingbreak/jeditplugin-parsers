function KeyboardShortcut(lib , def) {

	var componentName = def.ven + ' ' + def.app + ' ' + def.com + ' v' + def.version.replace(/\./mgi, '_');
	
	def.directive('focusable', function(){
		return {
			restrict: 'A',
			link: function (scope, element, attrs, ctrl){
				scope.$watch('currentIndex', function(newVal, oldVal, scope){
					setTimeout(function(){
						element.find('p').eq(newVal).find('.fakeSelect > input').focus();
					}, 4);
				});
			}
		};
	});

	/**
	this is test comment.
	@param dirName
	@return a directive defination
	*/
	def.directive('shortcut', function(dirName){
			return {
				restrict: 'A',
				link: function (scope, element, attrs, ctrl) {
					element.addClass(componentName);
					scope.focusedEntryIdx = 0;
					
					function upArrowPressed(){
						var idx = scope.focusedEntryIdx;
						if(idx > 0){
							scope.focusedEntryIdx--;
						}else if(idx === -1){
							scope.focusedEntryIdx = scope.listEntries.length -1;
						}
					}
					
					function downArrowPressed(){
						if(scope.focusedEntryIdx >= scope.listEntries.length || scope.focusedEntryIdx === -1){
							scope.focusedEntryIdx = -1;
						}else{
							scope.focusedEntryIdx ++;
						}
					}
					
					function enterPressed(){
						var buttons = element.find('li button');
						var itemButton = buttons.eq(scope.focusedEntryIdx);
						itemButton.addClass('selected');
						setTimeout(function(){
								scope.$apply(function(){
									if(scope.focusedEntryIdx === -1){
										scope.select();
								       }else{
										scope.select(scope.listEntries[scope.focusedEntryIdx]);
									}
								});
						}, 80);
					}
					
					function renderFocusing(newIdx, oldIdx){
						var buttons = element.find('li button');
						
						if(oldIdx != null)
							buttons.eq(oldIdx).removeClass('focused');
						else if(newIdx !== -1)
							buttons.eq(-1).removeClass('focused');//in case last focused is item 'None'
						buttons.eq(newIdx).addClass('focused');
					}
					
					scope.$watch("listEntries", function(newVal, oldVal, scope){
							scope.focusedEntryIdx = 0;
							renderFocusing(0, null);
					});
					
					scope.$watch('focusedEntryIdx', function(newVal, oldVal, scope){
							renderFocusing(newVal, oldVal);
					});
					
					function setupKeyEventListener(el){
						el.on('keydown', function(evt){
							scope.$apply(function(){
								if(evt.which === 38){
									evt.stopPropagation();
									evt.preventDefault();
									upArrowPressed();
								}else if(evt.which === 40){
									evt.stopPropagation();
									evt.preventDefault();
									downArrowPressed();
								}else if(evt.which === 13){
									evt.stopPropagation();
									enterPressed();
								}
							});
						});
					}
					var searchBarEl = element.parent().find('input[type="text"]');
					if(searchBarEl != null && searchBarEl.length >0){
						setupKeyEventListener(searchBarEl);
					}
					setupKeyEventListener(element.parent());
				}
			};
	});
	return {};
}
