<?php

namespace App\Repository;

interface SiteRepositoryInterface
{
    public function getAll();
    public function getById($id);
    public function save();


}
