using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PuzzelManager : MonoBehaviour
{
    public Point[] pts ;
    Point startPt;

    private void Start()
    {
        foreach (Point p in pts)
            if (p.startPt) 
            {
                startPt = p;
                break;
            }
    }

    private void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Vector2 mosePos = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
            print(mosePos);
        }
    }

}
