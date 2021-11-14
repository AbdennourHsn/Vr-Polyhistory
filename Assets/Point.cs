using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Point : MonoBehaviour
{
    public List<Point> nighbers = new List<Point>();
    public PuzzelManager puzzel;
    public bool startPt;
    private void Awake()
    {
        puzzel = FindObjectOfType<PuzzelManager>();
    }

    private void Start()
    {
        nighbers.Add(GetTheUpPoint());
        nighbers.Add(GetTheRightPoint());
        nighbers.Add(GetTheDownPoint());
        nighbers.Add(GethTheLeftPoint());
    }


    public Point GetTheUpPoint()
    {
        Point UpNighber=null;
        float Distance = 0;
        bool first=false;
        foreach (Point p in puzzel.pts)
        {
            if(p.transform.position.x == this.transform.position.x && p.transform.position.y > this.transform.position.y)
            {
                if (!first)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    first = true;
                }
                if(Vector3.Distance(this.transform.position, p.transform.position) <= Distance)
                {
                    Distance= Vector3.Distance(this.transform.position, p.transform.position);
                    UpNighber = p;
                    print("Im in");
                }
               
            }
        }
        return UpNighber;
    }
    public Point GetTheDownPoint()
    {
        Point DownNighber = null;
        float Distance = 0;
        bool first = false;
        foreach (Point p in puzzel.pts)
        {
            if (p.transform.position.x == this.transform.position.x && p.transform.position.y < this.transform.position.y)
            {
                if (!first)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    first = true;
                }
                if (Vector3.Distance(this.transform.position, p.transform.position) <= Distance)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    DownNighber = p;
                }
            }
        }
        return DownNighber;
    }
    public Point GetTheRightPoint()
    {
        Point rightNighber = null;
        float Distance = 0;
        bool first = false;
        foreach (Point p in puzzel.pts)
        {
            if (p.transform.position.y == this.transform.position.y && p.transform.position.x > this.transform.position.x)
            {
                if (!first)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    first = true;
                }
                if (Vector3.Distance(this.transform.position, p.transform.position) <= Distance)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    rightNighber = p;
                }
            }
        }
        return rightNighber;
    }
    public Point GethTheLeftPoint()
    {
        Point leftNighber = null;
        float Distance = 0;
        bool first = false;
        foreach (Point p in puzzel.pts)
        {
            if (p.transform.position.y == this.transform.position.y && p.transform.position.x < this.transform.position.x)
            {
                if (!first)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    first = true;
                }
                if (Vector3.Distance(this.transform.position, p.transform.position) <= Distance)
                {
                    Distance = Vector3.Distance(this.transform.position, p.transform.position);
                    leftNighber = p;
                }
            }
        }
        return leftNighber;
    }
}
