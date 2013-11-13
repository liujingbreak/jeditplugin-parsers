function InlineHelpPanel(lib , def) {

	var componentName = def.ven + ' ' + def.app + ' ' + def.com + ' v' + def.version.replace(/\./g, '_');
	
	def.directive('content', function(dirName) {
		var helpBriefFadingTime = 210,
			helpMainResizingTime = 310,
			helpMainFadingTime = 260;
		return {
			restrict: 'A',
			transclude: true,
			replace: true,
			link: function (scope, element, attrs, ctrl) {
				var mainEl =null,
					briefEl = null,
					self = {}, 
					helpId = attrs[dirName];
				scope.inlineHelpVisible = false;
				scope.className = '-collapsed';
				// collapes animation Step - 1
				function aniMainFadeOut(){
					var df = lib.q.defer();
					mainEl.css({
						'opacity':'0'
					});
					element.css('height', element.height()+"px");
					setTimeout(function(){
							scope.$apply(function(){
								scope.inlineHelpVisible = false;
							});
							df.resolve();
					}, helpMainFadingTime);
					return df.promise;
				}
				// collapes animation Step - 2
				function aniMainCollapes(){
					var df = lib.q.defer();
					element.addClass('resizing');
					element.css({
						height:"44px"
					});
					
					setTimeout(function(){
						element.removeClass('resizing');
						df.resolve();
					}, helpMainResizingTime);
					
					
					return df.promise;
				}
				// collapes animation Step - 3
				function aniBriefShow(){
					var df = lib.q.defer();
					briefEl.css({'opacity': "0"});
					
					scope.$apply(function(){
							scope.className = '-collapsed';
					});
					
					setTimeout(function(){
							element.css({height:'auto'});
							briefEl.addClass('brief-fading');
							briefEl.css({'opacity': "1"});
							
					}, 10);
					setTimeout(function(){
							briefEl.removeClass('brief-fading');
						df.resolve();
					}, helpBriefFadingTime);
					return df.promise;
				}
				
				// expand animation Step - 1
				function aniBriefHide(){
					var df = lib.q.defer();
					briefEl.addClass('brief-fading');
					briefEl.css({'opacity': "0"});
					
					element.css({height: element.height() +"px"});
					
					setTimeout(function(){
							scope.$apply(function(){
								scope.className = '';
							});
							setTimeout(function(){
									briefEl.removeClass('brief-fading');
									df.resolve();
							}, 10);
					}, helpBriefFadingTime);
					return df.promise;
				}
				// expand animation Step - 2
				function aniMainExpand(){
					var df = lib.q.defer();
					element.addClass('resizing');
					mainEl.css('opacity','0');
					scope.$apply(function(){
						scope.inlineHelpVisible = true;
					});
					setTimeout(function(){
						element.css({height: mainEl.outerHeight()+"px"});
						setTimeout(function(){
								element.removeClass('resizing');
								element.css({height:"auto"});
								df.resolve();
						}, helpMainResizingTime);
					}, 10);
					
					return df.promise;
				}
				// expand animation Step - 3
				function aniMainFadeIn(){
					var df = lib.q.defer();
					mainEl.css('opacity','1');
					setTimeout(function(){
							df.resolve();
					}, helpMainFadingTime);
					return df.promise;
				}
				
				function collapesAnimation(el){
					mainEl = el.find('.help-main');
					briefEl = el.find('.brief');
					aniMainFadeOut().then(aniMainCollapes).then(aniBriefShow).end();
				}
				
				function expandAnimation(el){
					mainEl = el.find('.help-main');
					briefEl = el.find('.brief-collapsed');
					aniBriefHide().then(aniMainExpand).then(aniMainFadeIn).end();
				}
				
				scope.collapseHelp = function(){
					lib.helpService.setHelpVisible(helpId, false);
					collapesAnimation(element);
					lib.talk.broadcast('help:visibleChange', {helpId: helpId, visible: false, src: self});
				};
				
				scope.expandHelp = function(){
					//scope.className = '';
					lib.helpService.setHelpVisible(helpId, true);
					expandAnimation(element);
					lib.talk.broadcast('help:visibleChange', {helpId: helpId, visible: true, src: self});
				};


				lib.helpService.isHelpVisible(helpId).then(function(status){
					scope.$apply(function(){
						scope.className = status ? '' : '-collapsed';
						scope.inlineHelpVisible = status;
					});
				}).end();
				
				element.find('.expand-trigger').on('click', function(){
					scope.$apply(scope.expandHelp);
				});
				
				element.find('.close-button').on('click', function(){
					scope.$apply(scope.collapseHelp);
				});

				lib.talk.subscribe('help:visibleChange', function(data){
					if( data.src === self) return; // don't trigger itself
					if (helpId === data.helpId){
						scope.className = data.visible ?  '' : '-collapsed';
						scope.inlineHelpVisible = data.visible;
					}
				});
			},

			template: '<div class="' + componentName + ' tst-help-panel" ng-show="brief != null || inlineHelpVisible">' +
						'<div ng-class="\'tst-brief brief\'+className" ng-show="brief != null">'+

							'<i ng-class="iconClass(coding)" class="ts-warning"></i>' +
							'{{brief}} | <span class="expand-trigger" >{{question}}</span>' +
						'</div>' +
						'<div ng-class="{\'tst-help-main help-main main\':inlineHelpVisible, \'tst-help-main help-main main-collapsed\':!inlineHelpVisible}">' +
							'<button class="close-button {{closeButton}}">' +
								'<i class="ts-close"></i>' +
							'</button>' +
							'<div class="content" ng-transclude></div>' +
						'</div>' +
					  '</div>',
			scope:{
				question:'@',
				brief:'@',
				closeButton: '@'
			}
		};
	});

	return {};
}
