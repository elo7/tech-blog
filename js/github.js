define('github', ['doc', 'ajax'], function($, ajax) {
	var GITHUB_URI = 'https://api.github.com/users/';

	var getUserInfo = function(size, user) {
		var userInfo;
		ajax.get(GITHUB_URI + user, {}, {
			success: function(response, xhr) {
				userInfo = {
					avatar: response.avatar_url + '&size=' + size,
					name: response.name,
				};
			}
		})

		return userInfo;
	};

	return {
		getInfoFromUsers: function(size, listOfUsers) {
			var listOfInfo = [];
			listOfUsers.forEach( function(currentValue) {
				var userInfo = getUserInfo(size, currentValue);

				if (userInfo) {
					listOfInfo.push({user: currentValue, avatarUrl: userInfo.avatar, name: userInfo.name});
				}
			});

			return listOfInfo;
		}
	}
});
