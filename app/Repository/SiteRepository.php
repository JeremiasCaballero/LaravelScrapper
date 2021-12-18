<?php

namespace App\Repository;
use App\Models\Site;

class SiteRepository implements SiteRepositoryInterface
{
    public function getAll() : array
    {
        $sites = [];
        foreach (Site::all() as $site) {
            array_push($sites, $site);
        }
        return $sites;
    }

    public function getById($id)
    {
        // TODO: Implement getById() method.
    }

    public function save()
    {
        // TODO: Implement save() method.
    }
}
