from django.db import models

from django.contrib.auth.models import User

class Tutorial(models.Model):
    """
    This table holds information about each tutorial hosted on the website
    Tutorials can be contained within tracks - but a tutorial doesn't know that
    """
    title          = models.CharField(max_length=128, unique=True)
    content        = models.TextField()
    date           = models.DateField()
    category       = models.ForeignKey('Category')
    slug           = models.CharField(max_length=128, unique=True)
    post_image     = models.URLField(max_length=256)
    excerpt        = models.CharField(max_length=512)
    author         = models.ForeignKey(User)

    def __unicode__(self):
        return self.title

class Category(models.Model):
    title = models.CharField(max_length=256, unique=True)
    desc  = models.CharField(max_length=1024, blank=True)

    def __unicode__(self):
        return self.title

class Track(models.Model):
    """
    This table contains information about tutorial tracks
    """
    title = models.CharField(max_length=256, unique=True)
    tutorials = models.ManyToManyField(Tutorial, through='TrackTutorials')

    def __unicode__(self):
        return self.title

class TrackTutorials(models.Model):
    """
    This table stores which tutorials belong to which tracks
    """
    track    = models.ForeignKey("Track")
    tutorial = models.ForeignKey("Tutorial")
    order    = models.IntegerField(default=0)


class Quiz(models.Model):
    """
    This table holds information about quizzes hosted on the website
    """
    title = models.CharField(max_length=128)

    def __unicode__(self):
        return self.title
