define(['doc', 'github'], function($, github) {

	var $avatar = $('.avatar'),
		userName = $('.publisher-info .github').text(),
		$user = $('.info .name'),
		listOfInfo = github.getInfoFromUsers('100', [userName]);

	listOfInfo.forEach(function(currentUser) {
		if (currentUser.user == userName) {
			if($avatar.isPresent() && userName) {
				$avatar.removeClass('hide');
				$avatar.find('img').attr('src', currentUser.avatarUrl);
			}

			if ($user.isPresent() && currentUser.name) {
				$user.text(currentUser.name);
			}
		}
	});
});
