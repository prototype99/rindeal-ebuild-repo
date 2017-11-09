#!/usr/bin/env python3
# Copyright 2016-2017 Jan Chren (rindeal) <dev.rindeal@gmail.com>
# Distributed under the terms of the GNU General Public License v2

import os
import portage

class EbuildRepoToolbox:

	@staticmethod
	def locate_repo_root(start_dir=None):
		d = os.getcwd() if start_dir is None else start_dir

		while d and d != "/":
			with os.scandir(d) as entries:
				for entry in entries:
					if entry.is_dir() and entry.name == "profiles":
						if os.path.exists(os.path.join(entry.path, "repo_name")):
							return d
			d = os.path.dirname(d)

		return None

	@classmethod
	def setup_working_environment(cls, repo_dir=None):
		if repo_dir is None:
			repo_dir = cls.locate_repo_root()

		os.chdir(repo_dir)
		os.environ["PORTDIR_OVERLAY"] = repo_dir

	@staticmethod
	def get_portage_dbapi():
		return portage.db[portage.root]["porttree"].dbapi

	#@staticmethod
